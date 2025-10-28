import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailError = false;

  bool get _isFormFilled => _emailController.text.trim().isNotEmpty;

  bool _isValidEmail(String email) {
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onSendEmailPressed() async {
    final email = _emailController.text.trim();

    bool hasError = false;

    if (email.isEmpty) {
      _showError('Введите email');
      _emailError = true;
      hasError = true;
    } else if (!_isValidEmail(email)) {
      _showError('Некорректный email');
      _emailError = true;
      hasError = true;
    } else {
      _emailError = false;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Вызов Supabase для отправки письма со сменой пароля
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (!mounted) return;

      // Переход на экран смены пароля
      Navigator.pushNamed(context, '/reset-password');
    } on AuthException catch (e) {
      _emailError = true;
      _showError(e.message);
    } catch (e) {
      _emailError = true;
      _showError('Ошибка при отправке письма: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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

    // Размеры облака и лягушки
    final msgW = 232.0 * scaleW;
    final msgH = 68.0 * scaleH; // увеличено для текста

    // Приподнимаем облако выше
    final msgTop = 84.0 * scaleH;

    final frogW = 255.0 * scaleW;
    final frogH = 334.0 * scaleH;
    final frogTop = 174.0 * scaleH;

    final sheetHeight = 276.0 * scaleH; // белый блок

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
                    borderRadius:
                    BorderRadius.circular(20 * ((scaleW + scaleH) / 2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        offset: Offset(0, 9 * scaleH),
                        blurRadius: 23.3 * ((scaleW + scaleH) / 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Введи почту, указанную\nпри регистрации',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro Rounded',
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * ((scaleW + scaleH) / 2),
                      color: const Color(0xFF191919),
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

          // Белое поле с формой
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetHeight,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16 * scaleW,
                16 * scaleH,
                16 * scaleW,
                50 * scaleH,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30 * ((scaleW + scaleH) / 2)),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 8 * scaleH),
                    Text(
                      'Сменить пароль',
                      style: TextStyle(
                        fontSize: 20 * ((scaleW + scaleH) / 2),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18 * scaleH),

                    // === Email ===
                    _buildLabel('Электронная почта', scaleW, scaleH,
                        error: _emailError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _emailController,
                      hint: 'example@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _emailError,
                      onChanged: (v) {
                        if (_emailError) setState(() => _emailError = false);
                        setState(() {});
                      },
                    ),

                    SizedBox(height: 18 * scaleH),

                    // Кнопка "Отправить письмо"
                    SizedBox(
                      width: double.infinity,
                      height: 51 * scaleH,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSendEmailPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormFilled
                              ? const Color(0xFF81C784)
                              : const Color(0xFFC0E3C2),
                          elevation: 5,
                          shadowColor:
                          const Color(0xFF81C784).withOpacity(0.50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              69 * ((scaleW + scaleH) / 2),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20 * scaleW,
                          height: 20 * scaleW,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Text(
                          'Отправить письмо',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * ((scaleW + scaleH) / 2),
                            height: 19 / 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: mq.padding.bottom + 6 * scaleH),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Метка над полем
  Widget _buildLabel(String text, double scaleW, double scaleH,
      {bool error = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: error ? const Color(0xFFFF4D4D) : const Color(0xFF777777),
          fontSize: 14 * ((scaleW + scaleH) / 2),
        ),
      ),
    );
  }

  // Универсальное поле ввода
  Widget _buildFilledField({
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
    Widget? suffixIcon,
    bool hasError = false,
    TextInputType keyboardType = TextInputType.text,
    required double height,
    required double scaleW,
    required double scaleH,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(101 * ((scaleW + scaleH) / 2)),
        border: hasError
            ? Border.all(color: const Color(0xFFFF4D4D), width: 1.5)
            : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        obscuringCharacter: '*',
        keyboardType: keyboardType,
        onChanged: (value) {
          if (onChanged != null) onChanged(value);
          setState(() {});
        },
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 14 * ((scaleW + scaleH) / 2),
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF777777),
            fontSize: 14 * ((scaleW + scaleH) / 2),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scaleW,
            vertical: 0,
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
      ),
    );
  }
}
