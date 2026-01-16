import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

class Face6Exercises extends StatefulWidget {
  const Face6Exercises({super.key});

  @override
  State<Face6Exercises> createState() => _Face6ExercisesState();
}

class _Face6ExercisesState extends State<Face6Exercises> {
  bool _showCamera = false;
  bool _isChecked = false; // оставлено как в исходнике (в новом UI не используется)

  DateTime? releaseSince;
  DateTime? lastCountAt;
  final int refractoryMs = 200; // защита от двойного счёта на одном пике

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;

  String serverJsonOutput = '';
  Map<String, dynamic>? result;

  bool isTracking = false;
  bool isBaselineSet = false;

  double latestScore = 0.0; // сырая (0..1)
  double? smoothedS; // EMA
  double maxScore = 0.0; // наблюдаемый максимум (по сглаженному)

  // Состояния цикла: open -> strong -> open
  bool wasOpenLongEnough = false; // “готовность” после фазы open
  bool armed = false; // разрешён ли зачёт
  DateTime? openSince;

  // Параметры
  final double openThreshold = 0.1; // <= считаем глаза “открыты”
  int restOpenMs = 200; // сколько держать open перед новой попыткой

  double fracOfMax = 0.40;
  double baseMinThreshold = 0.20;

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

      if (!mounted) return;

      setState(() {
        result = decoded;
        serverJsonOutput = const JsonEncoder.withIndent('  ').convert(decoded);
      });

      final status = decoded["status"];
      if (status == "baseline_set") {
        // Разрешим первый повтор сразу после калибровки (как в исходнике)
        setState(() {
          isBaselineSet = true;
          wasOpenLongEnough = true;
          armed = true;
          openSince = null;
          smoothedS = null;
          maxScore = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Калибровка завершена."), duration: Duration(seconds: 2)),
        );
      }

      if (status == "tracking" && decoded["delta"] != null) {
        final delta = decoded["delta"] as Map<String, dynamic>;
        double s = 0.0;

        if (delta["relative_change"] is num) {
          s = (delta["relative_change"] as num).toDouble(); // уже 0..1
        } else if (delta["relative_change"] is num) {
          final rel = (delta["relative_change"] as num).toDouble();
          s = (rel > 1.0 ? (rel - 1.0) : rel).clamp(0.0, 1.0); // rel>1 -> rel-1
        }
        latestScore = s;

        // 2) EMA сглаживание
        const alpha = 0.5;
        smoothedS = (smoothedS == null) ? s : (alpha * s + (1 - alpha) * smoothedS!);
        final val = smoothedS ?? s;

        // 3) Обновляем максимум
        if (val > maxScore && val > 0.05) maxScore = val;

        // 4) Порог активации
        double activationThreshold = (maxScore > 0.1)
            ? math.max(baseMinThreshold, fracOfMax * maxScore)
            : baseMinThreshold;
        double releaseThreshold = math.max(openThreshold, activationThreshold - 0.03);

        final now = DateTime.now();

        // Реарм по release-порогу (а не по абсолютному openThreshold)
        final isBelowRelease = val <= releaseThreshold;
        if (isBelowRelease) {
          releaseSince ??= now;
          if (now.difference(releaseSince!).inMilliseconds >= restOpenMs) {
            wasOpenLongEnough = true;
            armed = true;
          }
        } else {
          releaseSince = null;
        }
        final isOpenNow = val <= openThreshold; // оставим только для логов

        // Активация + рефрактерный интервал
        final canCountAgain = lastCountAt == null ||
            now.difference(lastCountAt!).inMilliseconds >= refractoryMs;

        if (isBaselineSet &&
            wasOpenLongEnough &&
            armed &&
            val >= activationThreshold &&
            canCountAgain) {
          setState(() {
            repetitionCount++;
            wasOpenLongEnough = false;
            armed = false;
            maxScore = 0.0;
          });
          lastCountAt = now;
          releaseSince = null; // новый цикл потребует падения ниже releaseThreshold

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

        // Отладка (как в исходнике)
        debugPrint('s=${val.toStringAsFixed(3)} thr=${activationThreshold.toStringAsFixed(3)} '
            'open=$isOpenNow ready=$wasOpenLongEnough armed=$armed');
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
    final data = jsonEncode({"mode": "track", "exercise": "face_6", "image": base64Image});
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
    final data = jsonEncode({"mode": "init", "exercise": "face_6", "image": base64Image});
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

      // Сброс состояния (как в исходнике)
      wasOpenLongEnough = true; // разрешим первый зачёт сразу после init
      armed = true;
      openSince = null;

      smoothedS = null;
      latestScore = 0.0;
      maxScore = 0.0;
    });
    if (!(_cameraController?.value.isStreamingImages ?? false)) {
      _cameraController?.startImageStream(processCameraImage);
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    channel.sink.close();
    super.dispose();
  }

  // ---------- UI (тот же дизайн) ----------

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
                              side: const BorderSide(
                                color: Color(0xFFF5F5F5),
                                width: 1,
                              ),
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
                                Positioned.fill(
                                  child: Container(color: const Color(0xFFF2F2F2)),
                                ),
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
                  width: 207,
                  height: 21,
                  child: Center(
                    child: Text(
                      'Прищур',
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
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.zero,
        ),
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
          setState(() {
            _showCamera = true;
          });
          sendInit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
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
            child: Image.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
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
                  const SnackBar(
                    content: Text("Калибровка выполнена."),
                    duration: Duration(seconds: 2),
                  ),
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
                  const SnackBar(
                    content: Text("Начали!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _greenIconButton(
              assetPath: 'assets/exercise/ic_pause.png',
              iconSize: 24,
              onTap: () async {
                setState(() => isTracking = false);
                await _cameraController?.stopImageStream();
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
                  Center(
                    child: _showCamera
                        ? _exerciseButtonsBar3(context)
                        : _enableCameraButton(),
                  ),
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
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/newimage/happy.png',
                      width: 200,
                      height: 219,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Поздравляем!\nУпражнение выполнено.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
