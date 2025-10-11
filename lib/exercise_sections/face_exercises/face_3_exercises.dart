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
  bool _isChecked = false;

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;
  String serverJsonOutput = '';

  Map<String, dynamic>? result;
  bool isTracking = false;
  bool isBaselineSet = false;

  // Пороговая логика
  double maxSqueezeScore = 0.0;    // динамический максимум (наблюдаемый)
  double latestSqueeze = 0.0;

  // Состояния цикла: open -> soft -> strong -> open
  bool wasOpenLongEnough = false;
  bool softReached = false;

  DateTime? openSince;
  DateTime? softSince;
  DateTime? strongSince;

  // Параметры
  final int restOpenMs = 500;      // сколько держать "открыто" перед новой попыткой
  final int holdSoftMs = 250;      // удержание "слабо"
  final int holdStrongMs = 500;    // удержание "крепко"

  // Отсечки по-умолчанию (динамически подтянем от maxSqueezeScore)
  final double openThreshold = 0.12;  // <= этого — считаем глаза открыты
  // soft/strong вычислим динамически от maxSqueezeScore

  int repetitionCount = 0;
  bool _showCongratsImage = false;

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
                setState(() { _showCongratsImage = true; isTracking = false; });
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) Navigator.of(context).pushReplacementNamed('/home');
                });
              }
            }
          } else {
            strongSince = null; // вышли ниже strong → сброс удержания
          }
        }
        debugPrint('s=${s.toStringAsFixed(3)} soft=${softThr.toStringAsFixed(3)} '
            'strong=${strongThr.toStringAsFixed(3)} open=${(s<=openThreshold)} '
            'ready=$wasOpenLongEnough softReached=$softReached '
            'softHold=${softSince!=null} strongHold=${strongSince!=null}');
        // Можно выводить отладку:
        //print("s=${s.toStringAsFixed(3)} soft=${softThr.toStringAsFixed(3)} strong=${strongThr.toStringAsFixed(3)} open=${(s<=openThreshold)} ready=$wasOpenLongEnough softReached=$softReached");
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

      return img.Image.fromBytes(width: width, height: height, bytes: buffer.buffer, numChannels: 3);
    } catch (e) {
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
      //softTimer?.cancel();
      //strongTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Фон
            Positioned.fill(
              child: Image.asset(
                'assets/image/fon8.png',
                fit: BoxFit.cover,
              ),
            ),

            // Основное содержимое
            Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Упражнения для мимических мышц',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Инструкция ', style: TextStyle(color: Colors.purple)),
                        TextSpan(
                          text: 'Выполнение',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Зажмурь глаза: слабо → крепко',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      '$repetitionCount / 10',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _showCamera
                        ? (_cameraController != null &&
                        _cameraController!.value.isInitialized
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    )
                        : const Center(child: CircularProgressIndicator()))
                        : Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Твоя очередь, включишь камеру?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Image.asset(
                                'assets/image/video1.png',
                                width: 160,
                                height: 160,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isChecked = !_isChecked;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: _isChecked
                                    ? Border.all(color: Colors.green, width: 3)
                                    : null,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 24,
                                color: _isChecked ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isChecked && !_showCamera)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showCamera = true;
                      });
                      sendInit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text(
                      'Начать упражнение',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                if (_showCamera && !_showCongratsImage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: "init",
                          backgroundColor: Colors.green,
                          onPressed: () {
                            sendInit();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Калибровка выполнена."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text("👁️", style: TextStyle(fontSize: 24)),
                        ),
                        FloatingActionButton(
                          heroTag: "start",
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            startTracking();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Начали!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(Icons.play_arrow),
                        ),
                        FloatingActionButton(
                          heroTag: "stop",
                          backgroundColor: Colors.red,
                          onPressed: () async {
                            setState(() => isTracking = false);
                            await _cameraController?.stopImageStream();
                          },
                          child: const Icon(Icons.stop),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
            if (_showCongratsImage)
              Container(
                color: Colors.white.withOpacity(0.9),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/exercise_10_xp.png', // добавлен баннер
                      width: 280,
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/image/happy.png',
                      width: 200,
                      height: 200,
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

            Positioned(
              top: 30,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
