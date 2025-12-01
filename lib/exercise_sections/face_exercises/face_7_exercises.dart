import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

enum WinkExpected { none, left, right }

class Face7Exercises extends StatefulWidget {
  const Face7Exercises({super.key});

  @override
  State<Face7Exercises> createState() => _Face7ExercisesState();
}

class _Face7ExercisesState extends State<Face7Exercises> {

  bool _showCamera = false;

  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttleTimer;
  bool _isChecked = false;
  bool isTracking = false;
  bool isBaselineSet = false;
  bool _showCongratsImage = false;

  // Метрики
  double? sL, sR;        // сырые 0..1
  double? smL, smR;      // EMA
  double maxL = 0.0, maxR = 0.0;

  // FSM
  WinkExpected expected = WinkExpected.none;
  bool armed = false;
  DateTime? releaseSince;
  DateTime? lastCountAt;
  final int refractoryMs = 250;

  // Пороги/релиз
  final double openThreshold = 0.12; // "открыто"
  int restOpenMs = 250;

  // Динамика порогов: мягкие
  double fracOfMax = 0.45;
  double baseMin = 0.20;
  double easyCap = 0.30;      // потолок порога
  double releaseGap = 0.03;   // thr - release

  int repetitionCount = 0;
  bool _showCongrats = false;

  String serverJsonOutput = '';

  @override
  void initState() {
    super.initState();
    initializeCamera();
    connectWebSocket();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    final front = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.low, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void connectWebSocket() {
    const serverUrl = "ws://82.202.137.138:8000/ws";
    channel = WebSocketChannel.connect(Uri.parse(serverUrl));

    channel.stream.listen((message) {
      final decoded = json.decode(message);
      serverJsonOutput = const JsonEncoder.withIndent('  ').convert(decoded);

      final status = decoded["status"];
      if (status == "baseline_set") {
        setState(() {
          isBaselineSet = true;
          // Разрешаем начать с любого глаза
          expected = WinkExpected.none;
          armed = true;
          releaseSince = null;
          lastCountAt = null;
          smL = smR = null;
          maxL = maxR = 0.0;
          repetitionCount = 0;
        });
      }

      if (status == "tracking" && decoded["delta"] != null) {
        final delta = decoded["delta"] as Map<String, dynamic>;

        // 1) Парсинг: берем отдельные глаза
        double l = 0.0, r = 0.0;
        if (delta["left_close"] is num && delta["right_close"] is num) {
          l = (delta["left_close"] as num).toDouble().clamp(0.0, 1.0);
          r = (delta["right_close"] as num).toDouble().clamp(0.0, 1.0);
        } else {
          // Фоллбек: если прислали только relative_change — считаем одинаково (не идеально, но на крайний случай)
          final rel = (delta["relative_change"] as num?)?.toDouble() ?? 0.0;
          final s = rel > 1.0 ? (rel - 1.0).clamp(0.0, 1.0) : rel.clamp(0.0, 1.0);
          l = s; r = s;
        }
        sL = l; sR = r;

        // 2) EMA сглаживание (быстрее реагируем)
        const alpha = 0.5;
        smL = (smL == null) ? l : (alpha * l + (1 - alpha) * smL!);
        smR = (smR == null) ? r : (alpha * r + (1 - alpha) * smR!);
        final vL = smL!, vR = smR!;

        // 3) Обновляем per-eye максимум (чтобы порог был персональным)
        if (vL > maxL && vL > 0.05) maxL = vL;
        if (vR > maxR && vR > 0.05) maxR = vR;

        // 4) Пороги на каждый глаз
        double thrL = (maxL > 0.1) ? math.max(baseMin, fracOfMax * maxL) : baseMin;
        double thrR = (maxR > 0.1) ? math.max(baseMin, fracOfMax * maxR) : baseMin;
        thrL = math.min(thrL, easyCap);
        thrR = math.min(thrR, easyCap);

        double relL = math.max(openThreshold, thrL - releaseGap);
        double relR = math.max(openThreshold, thrR - releaseGap);

        const double thrCap = 0.30;
        thrL = math.min(thrL, thrCap);
        thrR = math.min(thrR, thrCap);

        final now = DateTime.now();

// 5) Реарм: оба глаза ниже своих release-порогов
        final bothReleased = (vL <= relL) && (vR <= relR);
        if (bothReleased) {
          releaseSince ??= now;
          if (now.difference(releaseSince!).inMilliseconds >= restOpenMs) {
            armed = true;
          }
        } else {
          releaseSince = null;
        }

        const double otherMargin = 0.1;
        const double diffGap = 0.1;

        final bool leftOtherOk = (vR <= relR + otherMargin) || ((vL - vR) >= diffGap);
        final bool rightOtherOk = (vL <= relL + otherMargin) || ((vR - vL) >= diffGap);

        final bool leftActive = vL >= thrL && leftOtherOk;
        final bool rightActive = vR >= thrR && rightOtherOk;

        final canCountAgain = lastCountAt == null || now.difference(lastCountAt!).inMilliseconds >= refractoryMs;

        bool counted = false;
        WinkExpected nextExpected = expected;

        if (isBaselineSet && armed && canCountAgain) {
          if (expected == WinkExpected.none) {
// Первый шаг считаем и задаём ожидание противоположного глаза
            if (leftActive) {
              counted = true;
              nextExpected = WinkExpected.right;
            } else if (rightActive) {
              counted = true;
              nextExpected = WinkExpected.left;
            }
          } else if (expected == WinkExpected.left && leftActive) {
// Ожидали левый — засчитываем
            counted = true;
            nextExpected = WinkExpected.right;
          } else if (expected == WinkExpected.right && rightActive) {
// Ожидали правый — засчитываем
            counted = true;
            nextExpected = WinkExpected.left;
          }
        }

        if (counted) {
          setState(() {
            repetitionCount++;
            expected = nextExpected; // теперь ждём другой глаз
            armed = false; // ждём релиз (оба глаза ниже rel-порогов)
            lastCountAt = now;
            releaseSince = null;
// ограничим рост максимумов, чтобы пороги не задирались
            maxL = math.min(maxL, 0.9);
            maxR = math.min(maxR, 0.9);
          });

          if (repetitionCount >= 20) {
            setState(() {
              _showCongratsImage = true; // ВАЖНО: этот флаг и используется в UI
              isTracking = false;
            });
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) Navigator.of(context).pushReplacementNamed('/home');
            });
          }
        }

        // Отладка
        debugPrint('L=${vL.toStringAsFixed(2)} thrL=${thrL.toStringAsFixed(2)} relL=${relL.toStringAsFixed(2)} | '
            'R=${vR.toStringAsFixed(2)} thrR=${thrR.toStringAsFixed(2)} relR=${relR.toStringAsFixed(2)} | '
            'armed=$armed expected=$expected count=$counted reps=$repetitionCount');
        setState(() {}); // обновим UI / отладку
      }
    });
  }

  void processCameraImage(CameraImage image) async {
    if (!isTracking || (_throttleTimer?.isActive ?? false)) return;
    _throttleTimer = Timer(const Duration(milliseconds: 200), () {});
    final converted = _toRGB(image);
    if (converted == null) return;
    final jpeg = img.encodeJpg(converted, quality: 50);
    final base64Image = base64Encode(jpeg);
    final data = jsonEncode({"mode": "track", "exercise": "face_7", "image": base64Image});
    channel.sink.add(data);
  }

  img.Image? _toRGB(CameraImage image) {
    try {
      final w = image.width, h = image.height;
      final y = image.planes[0].bytes;
      final buf = Uint8List(w * h * 3);
      for (int i = 0; i < w * h; i++) {
        final v = y[i];
        buf[i * 3 + 0] = v; buf[i * 3 + 1] = v; buf[i * 3 + 2] = v;
      }
      return img.Image.fromBytes(width: w, height: h, bytes: buf.buffer, numChannels: 3);
    } catch (_) { return null; }
  }

  void sendInit() async {
    if (!(_cameraController?.value.isInitialized ?? false)) return;
    final imgFile = await _cameraController!.takePicture();
    final bytes = await imgFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final data = jsonEncode({"mode": "init", "exercise": "face_7", "image": base64Image});
    channel.sink.add(data);
  }

  void startTracking() {
    if (!isBaselineSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сначала выполните калибровку.")),
      );
      return;
    }
    setState(() {
      isTracking = true;
      repetitionCount = 0;
      _showCongrats = false;
      armed = true;
      expected = WinkExpected.none; // первый — любой
      releaseSince = null;
      lastCountAt = null;
      smL = smR = null;
      maxL = maxR = 0.0;
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
                  'Поочерёдно закрывай левый и правый глаз',
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
                      '$repetitionCount / 20',
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

