import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

enum PuffExpected { none, left, right }

class Cheeks3Exercises extends StatefulWidget {
  const Cheeks3Exercises({super.key});

  @override
  State<Cheeks3Exercises> createState() => _Cheeks3ExercisesState();
}

class _Cheeks3ExercisesState extends State<Cheeks3Exercises> {
  CameraController? _cameraController;
  late WebSocketChannel channel;
  Timer? _throttle;
  bool _showCamera = false;

  // Состояния
  bool isBaselineSet = false;
  bool isTracking = false;
  bool _showCongratsImage = false;
  bool _isChecked = false;

  // Метрики (EMA)
  double? smL, smR;
  double maxL = 0.0, maxR = 0.0;

  // FSM
  PuffExpected expected = PuffExpected.none; // первый — любой
  bool armed = true; // можно засчитывать шаг
  DateTime? releaseSince;
  DateTime? releaseSinceSide; // реарм по предыдущей стороне
  // релиз правой щеки
  PuffExpected lastCounted = PuffExpected.none;
  DateTime? lastStepAt;
  final int refractoryMs = 200; // защита от двойного шага

  // Пороги/параметры
  final double openThreshold = 0.08; // “расслаблено”
  int restOpenMs = 200;              // держать “расслаблено” для реарма

  double fracOfMax = 0.35; // доля от наблюдаемого максимума
  double baseMin = 0.07;   // минимальный порог
  double easyCap = 0.25;   // потолок порога
  double releaseGap = 0.04; // thr - release

  // Допуски по “второй” щеке (или требование асимметрии)
  double otherMargin = 0.25; // допустимо чуть надуть вторую щеку
  double diffGap = 0.04;     // требуемая разница (активная − вторая)

  int repetitionCount = 0;

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

      final status = decoded["status"];
      if (status == "baseline_set") {
        setState(() {
          isBaselineSet = true;
          expected = PuffExpected.none;
          releaseSinceSide = null;
          lastCounted = PuffExpected.none; // первый — любой
          armed = true;
          releaseSince = null;
          lastStepAt = null;
          smL = smR = null;
          maxL = maxR = 0.0;
          repetitionCount = 0;
        });
      }

      if (status == "tracking" && decoded["delta"] != null) {
        final delta = decoded["delta"] as Map<String, dynamic>;
        // читаем значения 0..1
// читаем значения 0..1
        double l = (delta["left_puff_score"] as num?)?.toDouble() ??
            (delta["left_score"] as num?)?.toDouble() ??
            0.0;
        double r = (delta["right_puff_score"] as num?)?.toDouble() ??
            (delta["right_score"] as num?)?.toDouble() ??
            0.0;

// крайний фоллбек: если пришла только общая метрика
        if (l == 0.0 && r == 0.0 && delta["relative_change"] is num) {
          final s = (delta["relative_change"] as num).toDouble().clamp(0.0, 1.0);
          l = s; r = s;
        }
        l = l.clamp(0.0, 1.0);
        r = r.clamp(0.0, 1.0);
        // 2) EMA
        const alpha = 0.6;
        smL = (smL == null) ? l : (alpha * l + (1 - alpha) * smL!);
        smR = (smR == null) ? r : (alpha * r + (1 - alpha) * smR!);
        final vL = smL!, vR = smR!;

        // 3) Обновление максимумов (персональная адаптация)
        if (vL > maxL && vL > 0.03) maxL = vL;
        if (vR > maxR && vR > 0.03) maxR = vR;

        // 4) Пороги на стороны
        double thrL = (maxL > 0.1) ? math.max(baseMin, fracOfMax * maxL) : baseMin;
        double thrR = (maxR > 0.1) ? math.max(baseMin, fracOfMax * maxR) : baseMin;
        thrL = math.min(thrL, easyCap);
        thrR = math.min(thrR, easyCap);

        double relL = math.max(openThreshold, thrL - releaseGap);
        double relR = math.max(openThreshold, thrR - releaseGap);

        final now = DateTime.now();

        // 5) Реарм: обе щёки ниже своих release-порогов
// 5) Реарм ТОЛЬКО по предыдущей стороне
        const double releaseSoft = 0.02; // допуск к релиз-порогу
        final bool relaxedL = vL <= (relL + releaseSoft);
        final bool relaxedR = vR <= (relR + releaseSoft);

// Какая щека должна расслабиться? Это та, что была засчитана на прошлом шаге,
// она всегда противоположна текущему expected.
        final PuffExpected needRelax =
        (expected == PuffExpected.left) ? PuffExpected.right :
        (expected == PuffExpected.right) ? PuffExpected.left :
        PuffExpected.none;

        if (needRelax == PuffExpected.left) {
          if (relaxedL) {
            releaseSinceSide ??= now;
            if (now.difference(releaseSinceSide!).inMilliseconds >= restOpenMs) {
              armed = true;
            }
          } else {
            releaseSinceSide = null;
          }
        } else if (needRelax == PuffExpected.right) {
          if (relaxedR) {
            releaseSinceSide ??= now;
            if (now.difference(releaseSinceSide!).inMilliseconds >= restOpenMs) {
              armed = true;
            }
          } else {
            releaseSinceSide = null;
          }
        } else {
// первый цикл — можно требовать обе расслаблены
          if (relaxedL && relaxedR) {
            releaseSince ??= now;
            if (now.difference(releaseSince!).inMilliseconds >= restOpenMs) {
              armed = true;
            }
          } else {
            releaseSince = null;
          }
        }
        // 6) Активная щека: порог + допуск по второй ИЛИ асимметрия
        const double atCountOtherMargin = 0.04; // допускаем “поддув” второй щеки не более 0.02
        const double atCountDiffGap = 0.05; // активная щека должна быть минимум на 0.08 больше второй

// 6) Активная щека: первый шаг — мягче; далее — строго
// Первый шаг (expected == none): без требования сильной асимметрии, только "вторая почти отпущена"
        const double firstOtherMargin = 0.08; // допуск второй щеке на первом шаге

// Строгий режим (для последующих шагов)
        bool leftActive, rightActive;

        if (expected == PuffExpected.none) {
          final bool leftOtherRelaxedFirst = vR <= (relR + firstOtherMargin);
          final bool rightOtherRelaxedFirst = vL <= (relL + firstOtherMargin);

          leftActive = (vL >= thrL) && leftOtherRelaxedFirst;
          rightActive = (vR >= thrR) && rightOtherRelaxedFirst;
        } else {
          final bool leftOtherRelaxed = vR <= (relR + atCountOtherMargin);
          final bool rightOtherRelaxed = vL <= (relL + atCountOtherMargin);

          leftActive = (vL >= thrL) && leftOtherRelaxed && ((vL - vR) >= atCountDiffGap);
          rightActive = (vR >= thrR) && rightOtherRelaxed && ((vR - vL) >= atCountDiffGap);
        }
        // 7) Подсчёт с очередностью, первый шаг тоже считаем
        final canStep = lastStepAt == null || now.difference(lastStepAt!).inMilliseconds >= refractoryMs;

        bool counted = false;
        PuffExpected nextExpected = expected;

        if (isBaselineSet && armed && canStep) {
          if (expected == PuffExpected.none) {
            if (rightActive) { counted = true; nextExpected = PuffExpected.left; }
            else if (leftActive) { counted = true; nextExpected = PuffExpected.right; }
          } else if (expected == PuffExpected.left && leftActive) {
            counted = true; nextExpected = PuffExpected.right;
          } else if (expected == PuffExpected.right && rightActive) {
            counted = true; nextExpected = PuffExpected.left;
          }
        }

        if (counted) {
          setState(() {
            repetitionCount++;
            expected = nextExpected; // теперь ждём другую щёку
            armed = false;           // ждём релиз
            lastStepAt = now;
            releaseSince = null;
            releaseSinceSide = null;
            // ограничим рост максимумов
            maxL = math.min(maxL, 0.9);
            maxR = math.min(maxR, 0.9);
          });

          if (repetitionCount >= 20) {
            setState(() {
              _showCongratsImage = true;
              isTracking = false;
            });
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) Navigator.of(context).pop();
            });
          }
        }

        // Отладка (если нужно)
        debugPrint('L=${vL.toStringAsFixed(2)} thrL=${thrL.toStringAsFixed(2)} relL=${relL.toStringAsFixed(2)} | '
                   'R=${vR.toStringAsFixed(2)} thrR=${thrR.toStringAsFixed(2)} relR=${relR.toStringAsFixed(2)} | '
                   'expected=$expected armed=$armed counted=$counted reps=$repetitionCount');

        setState(() {});
      }
    });
  }

  void processCameraImage(CameraImage image) async {
    if (!isTracking || (_throttle?.isActive ?? false)) return;
    _throttle = Timer(const Duration(milliseconds: 200), () {});
    final converted = _toRGB(image);
    if (converted == null) return;
    final jpeg = img.encodeJpg(converted, quality: 50);
    final base64Image = base64Encode(jpeg);
    final data = jsonEncode({"mode": "track", "exercise": "cheeks_3", "image": base64Image});
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
    final data = jsonEncode({"mode": "init", "exercise": "cheeks_3", "image": base64Image});
    channel.sink.add(data);
  }

  void startTracking() {
    if (!isBaselineSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сначала калибровка: лицо нейтрально, щёки не надуты.")),
      );
      return;
    }
    setState(() {
      isTracking = true;
      _showCongratsImage = false;
      expected = PuffExpected.none; // первый — любой
      armed = true;
      releaseSince = null; lastStepAt = null;
      releaseSinceSide = null;
      smL = smR = null; maxL = maxR = 0.0; repetitionCount = 0;
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
                  'Упражнения для щек',
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
                  'Поочерёдно надувать левую и правую щеку',
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

