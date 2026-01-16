import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

class Face3Exercises extends StatefulWidget {
  const Face3Exercises({super.key});

  @override
  State<Face3Exercises> createState() => _Face3ExercisesState();
}

class _Face3ExercisesState extends State<Face3Exercises> {
  bool _showCamera = false;
  bool _isChecked = false; // оставлено как в исходнике (в новом UI не используется)

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;

  String serverJsonOutput = '';
  Map<String, dynamic>? result;

  bool isTracking = false;
  bool isBaselineSet = false;

  // Пороговая логика
  double maxSqueezeScore = 0.0; // динамический максимум (наблюдаемый)
  double latestSqueeze = 0.0;

  // Состояния цикла: open -> soft -> strong -> open
  bool wasOpenLongEnough = false;
  bool softReached = false;

  DateTime? openSince;
  DateTime? softSince;
  DateTime? strongSince;

  // Параметры
  final int restOpenMs = 500; // сколько держать "открыто" перед новой попыткой
  final int holdSoftMs = 250; // удержание "слабо"
  final int holdStrongMs = 500; // удержание "крепко"

  // Отсечки по-умолчанию (динамически подтянем от maxSqueezeScore)
  final double openThreshold = 0.12; // <= этого — считаем глаза открыты

  int repetitionCount = 0;
  bool _showCongratsImage = false;

  static const int _targetReps = 10;
  static const double _headerHeight = 118;

  static const Color _bg = Color(0xFFF9F9F9);
  static const Color _green = Color(0xFF81C784);

  @override
  void initState() {
    super.initState();
    initializeCamera();
    connectWebSocket();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    final frontCamera =
    cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController =
        CameraController(frontCamera, ResolutionPreset.low, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void connectWebSocket() {
    const serverUrl = "ws://82.202.137.138:8000/ws";
    channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    channel.stream.listen((message) {
      final decoded = json.decode(message);
      // print('SERVER JSON: $decoded');

      if (!mounted) return;

      setState(() {
        result = decoded;
        serverJsonOutput = const JsonEncoder.withIndent('  ').convert(decoded);
      });

      final status = decoded["status"];
      if (status == "baseline_set") {
        isBaselineSet = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Калибровка завершена."), duration: Duration(seconds: 2)),
        );
      }

      if (status == "tracking" && decoded["delta"] != null) {
        final delta = decoded["delta"] as Map<String, dynamic>;
        double s = 0.0;

        if (delta["squeeze_score"] is num) {
          s = (delta["squeeze_score"] as num).toDouble();
        } else if (delta["blink_score"] is num) {
          s = (delta["blink_score"] as num).toDouble();
        } else if (delta["left_ratio"] is num && delta["right_ratio"] is num) {
          final lr = (delta["left_ratio"] as num).toDouble();
          final rr = (delta["right_ratio"] as num).toDouble();
          s = math.max(0.0, 1.0 - (lr + rr) / 2.0);
        } else if (delta["relative_change"] is num) {
          final rel = (delta["relative_change"] as num).toDouble();
          s = math.max(0.0, rel - 1.0); // нормализуем к 0..1
        }
        latestSqueeze = s;

        // обновляем динамический максимум (игнорируем мелкий шум)
        if (s > maxSqueezeScore && s > 0.05) {
          maxSqueezeScore = s;
        }

        // Пороги: динамически от максимумов с безопасными нижними границами
        double softThr = (maxSqueezeScore > 0.1) ? (0.55 * maxSqueezeScore) : 0.30;
        if (softThr < 0.25) softThr = 0.25;

        double strongThr = (maxSqueezeScore > 0.1) ? (0.80 * maxSqueezeScore) : 0.55;
        if (strongThr < 0.50) strongThr = 0.50;
        if (strongThr < softThr + 0.08) strongThr = softThr + 0.08;

        final now = DateTime.now();

        // 1) "Открыто" — уходим ниже openThreshold достаточно долго
        if (s <= openThreshold) {
          openSince ??= now;
          if (now.difference(openSince!).inMilliseconds >= restOpenMs) {
            wasOpenLongEnough = true;
          }
          // пока открываем — сбрасываем таймеры удержания
          softReached = false;
          softSince = null;
          strongSince = null;
        } else {
          openSince = null;
        }

        // 2) Достичь "слабо" и удержать
        if (wasOpenLongEnough && !softReached) {
          if (s >= softThr) {
            softSince ??= now;
            if (now.difference(softSince!).inMilliseconds >= holdSoftMs) {
              softReached = true;
              strongSince = null; // начинаем отсчёт "крепко" с чистого листа
            }
          } else {
            softSince = null; // вышли ниже soft → сброс удержания
          }
        }

        // 3) Достичь "крепко" после "слабо" и удержать → засчитать повтор
        if (wasOpenLongEnough && softReached) {
          if (s >= strongThr) {
            strongSince ??= now;
            if (now.difference(strongSince!).inMilliseconds >= holdStrongMs) {
              setState(() {
                repetitionCount++;
                wasOpenLongEnough = false;
                softReached = false;
              });
              // после зачёта ждём новый цикл: снова "open ≥ restOpenMs"
              softSince = null;
              strongSince = null;

              if (repetitionCount >= 10) {
                setState(() {
                  _showCongratsImage = true;
                  isTracking = false;
                });
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) Navigator.of(context).pushReplacementNamed('/home');
                });
              }
            }
          } else {
            strongSince = null; // вышли ниже strong → сброс удержания
          }
        }

        debugPrint(
          's=${s.toStringAsFixed(3)} soft=${softThr.toStringAsFixed(3)} '
              'strong=${strongThr.toStringAsFixed(3)} open=${(s <= openThreshold)} '
              'ready=$wasOpenLongEnough softReached=$softReached '
              'softHold=${softSince != null} strongHold=${strongSince != null}',
        );
      }
    });
  }

  void processCameraImage(CameraImage image) async {
    if (!isTracking || (_throttleTimer?.isActive ?? false)) return;
    _throttleTimer = Timer(const Duration(milliseconds: 200), () {});

    final converted = convertToRGB(image);
    if (converted == null) return;

    final jpeg = img.encodeJpg(converted, quality: 50);
    final base64Image = base64Encode(jpeg);
    final data = jsonEncode({"mode": "track", "exercise": "face_3", "image": base64Image});
    channel.sink.add(data);
  }

  img.Image? convertToRGB(CameraImage image) {
    try {
      final width = image.width;
      final height = image.height;
      final yPlane = image.planes[0];
      final yBytes = yPlane.bytes;
      final buffer = Uint8List(width * height * 3);

      for (int i = 0; i < width * height; i++) {
        final y = yBytes[i];
        buffer[i * 3] = y;
        buffer[i * 3 + 1] = y;
        buffer[i * 3 + 2] = y;
      }

      return img.Image.fromBytes(
        width: width,
        height: height,
        bytes: buffer.buffer,
        numChannels: 3,
      );
    } catch (_) {
      return null;
    }
  }

  void sendInit() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final image = await _cameraController!.takePicture();
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final data = jsonEncode({"mode": "init", "exercise": "face_3", "image": base64Image});
    channel.sink.add(data);
  }

  void startTracking() {
    if (!isBaselineSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сначала выполните калибровку."), duration: Duration(seconds: 2)),
      );
      return;
    }
    setState(() {
      isTracking = true;
      repetitionCount = 0;
      _showCongratsImage = false;
      wasOpenLongEnough = false;
      softReached = false;
      maxSqueezeScore = 0.0;
    });
    _cameraController?.startImageStream(processCameraImage);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    channel.sink.close();
    super.dispose();
  }

  // -------------------- UI (новый дизайн) --------------------

  Widget _topHeader(BuildContext context) {
    final progress = (repetitionCount.clamp(0, _targetReps)) / _targetReps.toDouble();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _headerHeight,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _headerHeight,
          child: Center(
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.end,
              runAlignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: 343,
                  height: 34,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: Material(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFFF5F5F5), width: 1),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: Image.asset(
                                  'assets/exercise/arrow_left.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 243,
                          height: 34,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2112),
                            child: Stack(
                              children: [
                                Positioned.fill(child: Container(color: const Color(0xFFF2F2F2))),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: progress == 0 ? 0.01 : progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _green,
                                          borderRadius: BorderRadius.circular(56),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '$repetitionCount/$_targetReps',
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 15,
                                      height: 18 / 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF191919),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 260,
                  height: 21,
                  child: Center(
                    child: Text(
                      'Зажмуривание',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 18,
                        height: 21 / 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _videoArea() {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: _bg),
        child: _showCamera
            ? (_cameraController != null && _cameraController!.value.isInitialized
            ? FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        )
            : const Center(child: CircularProgressIndicator()))
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Твоя очередь, включишь камеру?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/newimage/frog1.png',
                width: 200,
                height: 262,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _enableCameraButton() {
    return SizedBox(
      width: 247,
      height: 37,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _showCamera = true);
          sendInit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 0,
        ),
        child: const Text(
          'Включить камеру',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 21 / 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _greenIconButton({
    required String assetPath,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Material(
        color: _green,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Image.asset(assetPath, width: iconSize, height: iconSize, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _exerciseButtonsBar3(BuildContext context) {
    if (!_showCamera || _showCongratsImage) return const SizedBox.shrink();

    return SizedBox(
      height: 102,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _greenIconButton(
              assetPath: 'assets/exercise/ic_calibrate.png',
              iconSize: 39,
              onTap: () {
                sendInit();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Калибровка выполнена."), duration: Duration(seconds: 2)),
                );
              },
            ),
            const SizedBox(width: 8),
            _greenIconButton(
              assetPath: 'assets/exercise/ic_play.png',
              iconSize: 24,
              onTap: () {
                startTracking();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Начали!"), duration: Duration(seconds: 2)),
                );
              },
            ),
            const SizedBox(width: 8),
            _greenIconButton(
              assetPath: 'assets/exercise/ic_pause.png',
              iconSize: 24,
              onTap: () {
                setState(() => isTracking = false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            _topHeader(context),
            Positioned.fill(
              top: _headerHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _videoArea(),
                  const SizedBox(height: 8),
                  Center(child: _showCamera ? _exerciseButtonsBar3(context) : _enableCameraButton()),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (_showCongratsImage)
              Container(
                color: Colors.white.withValues(alpha: 0.9),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/newimage/happy.png', width: 200, height: 219),
                    const SizedBox(height: 20),
                    const Text(
                      'Поздравляем!\nУпражнение выполнено.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
