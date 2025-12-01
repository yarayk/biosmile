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
  bool _isChecked = false;
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

  double latestScore = 0.0;   // сырая (0..1)
  double? smoothedS;          // EMA
  double maxScore = 0.0;      // наблюдаемый максимум (по сглаженному)

  // Состояния цикла: open -> strong -> open
  bool wasOpenLongEnough = false; // “готовность” после фазы open
  bool armed = false;             // разрешён ли зачёт
  DateTime? openSince;

  // Параметры
  final double openThreshold = 0.1;  // <= считаем глаза “открыты”
  int restOpenMs = 200;               // сколько держать open перед новой попыткой

  double fracOfMax = 0.40;
  double baseMinThreshold = 0.20;

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

      setState(() {
        result = decoded;
        serverJsonOutput = const JsonEncoder.withIndent('  ').convert(decoded);
      });

      final status = decoded["status"];
      if (status == "baseline_set") {
        // Разрешим первый повтор сразу после калибровки
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
        final canCountAgain = lastCountAt == null || now.difference(lastCountAt!).inMilliseconds >= refractoryMs;
        if (isBaselineSet && wasOpenLongEnough && armed && val >= activationThreshold && canCountAgain) {
          setState(() {
            repetitionCount++;
            wasOpenLongEnough = false;
            armed = false;
            maxScore = 0.0;
          });
          lastCountAt = now;
          releaseSince = null; // новый цикл потребует падения ниже releaseThreshold

          if (repetitionCount >= 10) {
            setState(() { _showCongratsImage = true; isTracking = false; });
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) Navigator.of(context).pushReplacementNamed('/home');
            });
          }
        }

        // Отладка
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

      // Сброс состояния
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
                  'Прищурься',
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
