import 'package:flutter/material.dart';
import '../auth_service.dart';

class AuthSignInWidget extends StatefulWidget {
  @override
  _AuthSignInWidgetState createState() => _AuthSignInWidgetState();
}

class _AuthSignInWidgetState extends State<AuthSignInWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _emailError = false;
  bool _passwordError = false;

  bool get _isFormFilled =>
      _emailController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty;

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

  Future<void> _onSignInPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    // Проверки ввода
    if (email.isEmpty) {
      _showError('Пожалуйста, введите email');
      _emailError = true;
      hasError = true;
    } else if (!_isValidEmail(email)) {
      _showError('Пожалуйста, введите корректный email');
      _emailError = true;
      hasError = true;
    } else {
      _emailError = false;
    }

    if (password.isEmpty) {
      _showError('Пожалуйста, введите пароль');
      _passwordError = true;
      hasError = true;
    } else {
      _passwordError = false;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Теперь signInWithEmail сам обрабатывает успешный вход и редирект
      await AuthService.signInWithEmail(
        context: context,
        email: email,
        password: password,
      );
    } catch (e) {
      // Ошибка аутентификации
      _passwordError = true;
      _showError('Ошибка входа: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

    final frogW = 255.0 * scaleW;
    final frogH = 334.0 * scaleH;
    final frogTop = 141.0 * scaleH;
    final msgW = 232.0 * scaleW;
    final msgH = 45.0 * scaleH;
    final msgTop = 74.0 * scaleH;
    final sheetHeight = 448.0 * scaleH;
    final buttonHeight = 51.0 * scaleH;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // === ФОН ===
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0],
                colors: [Color(0xFFECFFDE), Color(0xFFEEFFEF)],
              ),
            ),
          ),

          // === "Добро пожаловать" ===
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
                  child: Text(
                    'Добро пожаловать',
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

          // === Лягушонок ===
          Positioned(
            top: frogTop,
            left: (sw - frogW) / 2,
            child: SizedBox(
              width: frogW,
              height: frogH,
              child: Image.asset('assets/newimage/frog1.png', fit: BoxFit.contain),
            ),
          ),

          // === Форма входа ===
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: sheetHeight,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16 * scaleW, 16 * scaleH, 16 * scaleW, 50 * scaleH),
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
                      'Вход',
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

                    SizedBox(height: 12 * scaleH),

                    // === Пароль ===
                    _buildLabel('Пароль', scaleW, scaleH,
                        error: _passwordError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _passwordController,
                      hint: 'Введите пароль',
                      obscureText: _obscurePassword,
                      hasError: _passwordError,
                      onChanged: (v) {
                        if (_passwordError) setState(() => _passwordError = false);
                        setState(() {});
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20 * ((scaleW + scaleH) / 2),
                          color: _passwordError
                              ? const Color(0xFFFF4D4D)
                              : Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                    ),

                    SizedBox(height: 18 * scaleH),

                    // === Кнопка "Войти" ===
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSignInPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormFilled
                              ? const Color(0xFF81C784)
                              : const Color(0xFFC0E3C2),
                          elevation: 5,
                          shadowColor: const Color(0xFF81C784).withOpacity(0.5),
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
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Войти',
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

                    SizedBox(height: 12 * scaleH),

                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/forgot-password'),
                      child: Text(
                        'Забыли пароль?',
                        style: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 14 * ((scaleW + scaleH) / 2),
                        ),
                      ),
                    ),

                    SizedBox(height: 8 * scaleH),
                    Text(
                      'Или войдите в аккаунт, используя\nодин из сервисов',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF777777).withOpacity(0.5),
                        fontSize: 13 * ((scaleW + scaleH) / 2),
                      ),
                    ),

                    SizedBox(height: 12 * scaleH),

                    // === Соцсети ===
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton('assets/newimage/vk.png', () {}, scaleW, scaleH),
                        SizedBox(width: 16 * scaleW),
                        _socialButton('assets/newimage/yandex.png', () {}, scaleW, scaleH),
                        SizedBox(width: 16 * scaleW),
                        _socialButton('assets/newimage/gos.png', () {}, scaleW, scaleH),
                      ],
                    ),

                    SizedBox(height: mq.padding.bottom + 6 * scaleH),
                  ],
                ),
              ),
            ),
          ),

          // === Нижняя чёрная полоска ===
          Positioned(
            bottom: 8 * scaleH,
            left: (sw - 134 * scaleW) / 2 + 0.5 * scaleW,
            child: Container(
              width: 134 * scaleW,
              height: 5 * scaleH,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double scaleW, double scaleH, {bool error = false}) {
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
        border: hasError ? Border.all(color: const Color(0xFFFF4D4D), width: 1.5) : null,
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

  Widget _socialButton(String assetPath, VoidCallback onTap, double scaleW, double scaleH) {
    final double size = 44 * ((scaleW + scaleH) / 2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(9.625 * ((scaleW + scaleH) / 2)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: const Color(0xFFF5F5F5)),
        ),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Маленький треугольник под "Добро пожаловать"
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
