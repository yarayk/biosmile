// cheek_puff_exercise.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

class Cheeks1Exercises extends StatefulWidget {
  const Cheeks1Exercises({super.key});

  @override
  State<Cheeks1Exercises> createState() => _Cheeks1ExercisesState();
}

class _Cheeks1ExercisesState extends State<Cheeks1Exercises> {
  bool _showCamera = false;
  bool _isChecked = false;

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;

  Map<String, dynamic>? result;
  bool isTracking = false;
  bool isBaselineSet = false;
  double maxCheekRatio = 0;
  int repetitionCount = 0;

  bool cheekAboveThreshold = false;
  bool wasRelaxedBeforePuff = false;
  Timer? holdTimer;
  double? latestRelativeCheek;
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
    _cameraController = CameraController(frontCamera, ResolutionPreset.low, enableAudio: false);
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
        final status = decoded["status"];
        if (status == "baseline_set") {
          isBaselineSet = true;
          startTracking();
        }
      });
      print("WS: $decoded");
      if (decoded["status"] == "tracking" && decoded["delta"] != null) {
        double current = decoded["delta"]["relative_change"] ?? 0.0;
        latestRelativeCheek = current;

        if (maxCheekRatio > 0) {
          double threshold = 1.0 + (maxCheekRatio - 1.0) * 0.5; // (1 + max)/2

          if (current < threshold) {
            wasRelaxedBeforePuff = true;
            cheekAboveThreshold = false;
            holdTimer?.cancel();
          }

          if (current >= threshold && !cheekAboveThreshold && wasRelaxedBeforePuff) {
            cheekAboveThreshold = true;
            holdTimer = Timer(const Duration(milliseconds: 300), () {
              if (cheekAboveThreshold) {
                setState(() {
                  repetitionCount++;
                  wasRelaxedBeforePuff = false;

                });

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
            });
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
    final data = jsonEncode({"mode": "track", "exercise": "cheeks_2", "image": base64Image});
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
    final data = jsonEncode({"mode": "init", "exercise": "cheeks_2", "image": base64Image});
    channel.sink.add(data);
  }

  void saveMaxCheek() {
    if (latestRelativeCheek != null) {
      setState(() {
        maxCheekRatio = latestRelativeCheek!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Максимальное положение щек сохранено."),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      cheekAboveThreshold = false;
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
            Positioned.fill(
              child: Image.asset('assets/image/fon8.png', fit: BoxFit.cover),
            ),
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
                    TextSpan(children: [
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
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Нахмурь брови и удержи',
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
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
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
                        ? (_cameraController != null && _cameraController!.value.isInitialized
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
                              setState(() => _isChecked = !_isChecked);
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
                      setState(() => _showCamera = true);
                      sendInit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Начать упражнение', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                          onPressed: sendInit,
                          child: const Text("😐", style: TextStyle(fontSize: 24)),
                        ),
                        FloatingActionButton(
                          heroTag: "save",
                          backgroundColor: Colors.blue,
                          onPressed: saveMaxCheek,
                          child: const Text("😠", style: TextStyle(fontSize: 24)),
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
                            setState(() => isTracking = false);
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
                      'assets/image/exercise_10_xp.png',
                      width: 280,
                    ),
                    const SizedBox(height: 20),
                    Image.asset('assets/image/happy.png', width: 200, height: 200),
                    const SizedBox(height: 20),
                    const Text(
                      'Поздравляем!\nУпражнение выполнено.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),

            Positioned(
              top: 30,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
