import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

class Face4Exercises extends StatefulWidget {
  const Face4Exercises({super.key});

  @override
  State<Face4Exercises> createState() => _Face4ExercisesState();
}

class _Face4ExercisesState extends State<Face4Exercises> {
  bool _showCamera = false;
  bool _isChecked = false;
  final int minBlinkDurationMs = 100; // минимум 100 мс закрытия — чтобы исключить шум

  DateTime? eyesClosedAt;
  DateTime? eyesOpenedAt;
  bool eyesAreClosed = false;
  final int requiredClosedDuration = 500; // миллисекунд
  final int requiredOpenedDuration = 500;



  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;
  String serverJsonOutput = '';

  Map<String, dynamic>? result;
  bool isTracking = false;
  bool isBaselineSet = false;
  double maxBlinkScore = 0;
  int repetitionCount = 0;
  bool blinkAboveThreshold = false;

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
    const serverUrl = "ws://82.202.137.138:8000/ws"; // адаптируй при необходимости
    channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    channel.stream.listen((message) {
      final decoded = json.decode(message);
      print('SERVER JSON: $decoded');

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
      // функция для моргания
      if (status == "tracking" && decoded["delta"] != null) {
        double currentBlink = decoded["delta"]["blink_score"] ?? 0.0;

        if (!isBaselineSet) return;

        if (maxBlinkScore == 0 && currentBlink > 0.01) {
          maxBlinkScore = currentBlink;
          return;
        }

        double threshold = maxBlinkScore * 0.8;
        final now = DateTime.now();

        if (currentBlink >= threshold) {
          // глаза ЗАКРЫТЫ
          if (!eyesAreClosed) {
            eyesAreClosed = true;
            eyesClosedAt = now;
          }

          // Проверим, что глаза были открыты перед этим достаточно долго
          if (eyesOpenedAt != null &&
              now.difference(eyesOpenedAt!).inMilliseconds >= requiredOpenedDuration &&
              eyesClosedAt != null &&
              now.difference(eyesClosedAt!).inMilliseconds >= requiredClosedDuration) {
            // Считаем моргание
            repetitionCount++;
            eyesOpenedAt = null;
            eyesClosedAt = now; // обновим заново

            print("✅ Засчитано моргание: $repetitionCount");

            if (repetitionCount >= 10) {
              setState(() {
                _showCongratsImage = true;
                isTracking = false;
              });

              Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              });
            }
          }
        } else {
          // глаза ОТКРЫТЫ
          if (eyesAreClosed) {
            eyesAreClosed = false;
            eyesOpenedAt = now;
          }
        }
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
    final data = jsonEncode({"mode": "track", "exercise": "face_4", "image": base64Image});
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
    final data = jsonEncode({"mode": "init", "exercise": "face_4", "image": base64Image});
    channel.sink.add(data);
  }


  void startTracking() {
    if (!isBaselineSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Сначала выполните калибровку."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isTracking = true;
      repetitionCount = 0;
      blinkAboveThreshold = false;
      _showCongratsImage = false;
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
                  'Поморгай',
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
                          onPressed: () {
                            setState(() {
                              isTracking = false;
                            });
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
