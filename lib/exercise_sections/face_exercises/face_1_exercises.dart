// brow_exercise.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

class Face1Exercises extends StatefulWidget {
  const Face1Exercises({super.key});

  @override
  State<Face1Exercises> createState() => _Face1ExercisesState();
}

class _Face1ExercisesState extends State<Face1Exercises> {
  bool _showCamera = false;

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;

  Map<String, dynamic>? result;
  bool isTracking = false;
  bool isBaselineSet = false;

  double maxLiftRatio = 0;
  int repetitionCount = 0;

  bool browAboveThreshold = false;
  bool wasLoweredBeforeLift = false;
  Timer? holdTimer;
  double? latestRelativeLift;

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
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _cameraController =
        CameraController(frontCamera, ResolutionPreset.low, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void connectWebSocket() {
    const serverUrl = "ws://82.202.137.138:8000/ws";
    final uri = Uri.parse(serverUrl);
    debugPrint(
        'WS uri=${uri.toString()} host=${uri.host} port=${uri.port} scheme=${uri.scheme}');

    channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    channel.stream.listen((message) {
      final decoded = json.decode(message);

      if (!mounted) return;

      setState(() {
        result = decoded;
        final status = decoded["status"];
        if (status == "baseline_set") {
          isBaselineSet = true;
          startTracking(); // как было в исходнике
        }
      });

      if (decoded["status"] == "tracking" && decoded["delta"] != null) {
        final delta = decoded["delta"];
        final rawLift = (delta is Map) ? delta["relative_lift"] : null;
        final double currentLift =
        (rawLift is num) ? rawLift.toDouble() : 0.0;

        latestRelativeLift = currentLift;

        if (maxLiftRatio > 0) {
          final double threshold = maxLiftRatio * 0.9;

          // 1) зафиксировали "сначала опусти"
          if (currentLift < threshold) {
            wasLoweredBeforeLift = true;
            browAboveThreshold = false;
            holdTimer?.cancel();
          }

          // 2) поднял выше порога и до этого был "опуск"
          if (currentLift >= threshold &&
              !browAboveThreshold &&
              wasLoweredBeforeLift) {
            browAboveThreshold = true;

            // 3) удержание 300ms как в исходнике
            holdTimer = Timer(const Duration(milliseconds: 300), () {
              if (!mounted) return;

              if (browAboveThreshold) {
                setState(() {
                  repetitionCount++;
                  wasLoweredBeforeLift = false;
                });

                if (repetitionCount >= _targetReps) {
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
    final data =
    jsonEncode({"mode": "track", "exercise": "face_1", "image": base64Image});
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final image = await _cameraController!.takePicture();
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final data =
    jsonEncode({"mode": "init", "exercise": "face_1", "image": base64Image});
    channel.sink.add(data);
  }

  void saveMaxLift() {
    if (latestRelativeLift != null) {
      setState(() {
        maxLiftRatio = latestRelativeLift!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Максимальное поднятие бровей сохранено."),
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
      browAboveThreshold = false;
      wasLoweredBeforeLift = false; // безопасно сбросить при старте
      holdTimer?.cancel();
      _showCongratsImage = false;
    });

    _cameraController?.startImageStream(processCameraImage);
  }

  void stopTracking() {
    // как было: просто выключаем флаг (стрим может продолжать идти, но кадры не будут слаться)
    setState(() {
      isTracking = false;
    });
  }

  @override
  void dispose() {
    holdTimer?.cancel();
    _throttleTimer?.cancel();
    _cameraController?.dispose();
    channel.sink.close();
    super.dispose();
  }

  Widget _topHeader(BuildContext context) {
    final progress =
        (repetitionCount.clamp(0, _targetReps)) / _targetReps.toDouble();

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
                                  child: Container(
                                    color: const Color(0xFFF2F2F2),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor:
                                      progress == 0 ? 0.01 : progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _green,
                                          borderRadius:
                                          BorderRadius.circular(56),
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
                      'Брови',
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
          color: _bg, // под цвет фона
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

  Widget _exerciseButtonsBar(BuildContext context) {
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
              assetPath: 'assets/exercise/ic_save_max.png',
              iconSize: 38,
              onTap: saveMaxLift,
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
              onTap: stopTracking,
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
                        ? _exerciseButtonsBar(context)
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
