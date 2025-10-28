import 'package:flutter/material.dart';
import 'dart:async';

// Маленький треугольник под облаком
class _TriangleDownPainter extends CustomPainter {
  final Color color;
  _TriangleDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const int _initialSeconds = 120;
  int _seconds = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = _initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  String get _timeFormatted {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _timerEnded => _seconds <= 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseW = 375.0;
    const baseH = 812.0;
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final scaleW = sw / baseW;
    final scaleH = sh / baseH;

    final msgW = 260.0 * scaleW;
    // УВЕЛИЧИЛИ облако! Было 68 -> теперь 90 (или подберите нужное значение)
    final msgH = 110.0 * scaleH;
    final msgTop = 84.0 * scaleH;
    final frogW = 255.0 * scaleW;
    final frogH = 334.0 * scaleH;
    final frogTop = 204.0 * scaleH;

    final sheetHeight = 176.0 * scaleH;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Фон
          Container(
            width: sw,
            height: sh,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0],
                colors: [Color(0xFFECFFDE), Color(0xFFEEFFEF)],
              ),
            ),
          ),

          // Стрелка назад
          Positioned(
            left: 16 * scaleW,
            top: 67 * scaleH,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34 * scaleW,
                height: 34 * scaleW,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
                  borderRadius: BorderRadius.circular(10.36 * scaleW),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4.6 * scaleW,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18 * scaleW,
                    color: const Color(0xFF191919),
                  ),
                ),
              ),
            ),
          ),

          // Облако подсказки и стрелочка
          Positioned(
            top: msgTop,
            left: (sw - msgW) / 2,
            child: Column(
              children: [
                Container(
                  width: msgW,
                  height: msgH,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20 * ((scaleW + scaleH) / 2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        offset: Offset(0, 9 * scaleH),
                        blurRadius: 23.3 * ((scaleW + scaleH) / 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      'Проверь почту, мы\nотправили письмо и\nрассказали, как сменить пароль',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro Rounded',
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * ((scaleW + scaleH) / 2),
                        color: const Color(0xFF191919),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size(16 * scaleW, 10 * scaleH),
                  painter: _TriangleDownPainter(color: Colors.white),
                ),
              ],
            ),
          ),

          // Лягушка
          Positioned(
            top: frogTop,
            left: (sw - frogW) / 2,
            child: SizedBox(
              width: frogW,
              height: frogH,
              child: Image.asset(
                'assets/newimage/frog1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Белый блок для кнопки
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetHeight,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16 * scaleW,
                24 * scaleH,
                16 * scaleW,
                36 * scaleH,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30 * ((scaleW + scaleH) / 2)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Таймер
                  Padding(
                    padding: EdgeInsets.only(bottom: 18 * scaleH),
                    child: Text(
                      _timeFormatted,
                      style: TextStyle(
                        color: const Color(0xFF777777),
                        fontSize: 15 * ((scaleW + scaleH) / 2),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Кнопка повторной отправки письма
                  SizedBox(
                    width: double.infinity,
                    height: 51 * scaleH,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/password-page');
                        _startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _timerEnded
                            ? const Color(0xFF81C784)
                            : const Color(0xFFC0E3C2),
                        elevation: 5,
                        shadowColor: const Color(0xFF81C784).withOpacity(0.50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            69 * ((scaleW + scaleH) / 2),
                          ),
                        ),
                      ),
                      child: Text(
                        'Отправить письмо повторно',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 16 * ((scaleW + scaleH) / 2),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
