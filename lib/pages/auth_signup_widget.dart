import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../auth_service.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';

class AuthSignUpWidget extends StatefulWidget {
  @override
  _AuthSignUpWidgetState createState() => _AuthSignUpWidgetState();
}

class _AuthSignUpWidgetState extends State<AuthSignUpWidget> {
  // controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  // focus nodes
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChecked = false;

  // UI error states
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _firstNameError = false;
  bool _lastNameError = false;

  // When password field loses focus with unmet rules => show failing rules as red.
  bool _showPasswordRulesFailed = false;

  // helpers
  bool _isValidEmail(String email) {
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _hasMinLength(String p) => p.length >= 8;
  bool _hasUppercase(String p) => p.contains(RegExp(r'[A-ZА-Я]'));
  bool _hasLowercase(String p) => p.contains(RegExp(r'[a-zа-я]'));
  bool _hasDigit(String p) => p.contains(RegExp(r'\d'));
  // special characters allowed: . _ -
  bool _hasSpecial(String p) => p.contains(RegExp(r'[._\-]'));

  bool _isValidPassword(String password) {
    return _hasMinLength(password) &&
        _hasUppercase(password) &&
        _hasLowercase(password) &&
        _hasDigit(password) &&
        _hasSpecial(password);
  }

  bool _isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s-]+$');
    return nameRegex.hasMatch(name);
  }

  // color helpers (matching sign-in design)
  static const Color _okGreen = Color(0xFF81C784);
  static const Color _mutedGreen = Color(0xFFC0E3C2);
  static const Color _dangerRed = Color(0xFFFF4D4D);

  // Form filled check (button color) — all required fields filled except middle name
  bool get _isFormFilled {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onCreatePressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final middleName = _middleNameController.text.trim();

    bool hasError = false;

    if (lastName.isEmpty) {
      _lastNameError = true;
      _showError('Пожалуйста, введите фамилию');
      hasError = true;
    } else if (!_isValidName(lastName)) {
      _lastNameError = true;
      _showError('Фамилия может содержать только буквы, пробелы и дефисы');
      hasError = true;
    } else {
      _lastNameError = false;
    }

    if (firstName.isEmpty) {
      _firstNameError = true;
      _showError('Пожалуйста, введите имя');
      hasError = true;
    } else if (!_isValidName(firstName)) {
      _firstNameError = true;
      _showError('Имя может содержать только буквы, пробелы и дефисы');
      hasError = true;
    } else {
      _firstNameError = false;
    }

    if (middleName.isNotEmpty && !_isValidName(middleName)) {
      _showError('Отчество может содержать только буквы, пробелы и дефисы');
      hasError = true;
    }

    if (!_isValidEmail(email)) {
      _emailError = true;
      _showError('Пожалуйста, введите корректный email');
      hasError = true;
    } else {
      _emailError = false;
    }

    // Проверяем каждое правило отдельно и даём аккуратные ошибки
    if (!_hasMinLength(password)) {
      _passwordError = true;
      _showError('Пароль должен содержать минимум 8 символов');
      hasError = true;
    } else if (!_hasUppercase(password) ||
        !_hasLowercase(password) ||
        !_hasDigit(password) ||
        !_hasSpecial(password)) {
      _passwordError = true;
      _showError('Пароль должен содержать:\n- заглавную букву\n- строчную букву\n- цифру\n- спецсимвол (., _, -)');
      hasError = true;
    } else {
      _passwordError = false;
    }

    if (password != confirm) {
      _confirmPasswordError = true;
      _showError('Пароли не совпадают');
      hasError = true;
    } else {
      _confirmPasswordError = false;
    }

    if (!_isChecked) {
      _showError('Пожалуйста, примите условия использования');
      hasError = true;
    }

    setState(() {}); // обновляем отображение ошибок

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.signUp(
        context: context,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
      );

      if (success) {
        Navigator.pushNamed(context, '/email-verification');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // update UI on each relevant change
  void _onAnyFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();

    // слушаем фокус пароля, чтобы при потере показать красные не выполненные правила
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        // поле потеряло фокус
        final p = _passwordController.text;
        final anyFailed = !(_hasMinLength(p) &&
            _hasUppercase(p) &&
            _hasLowercase(p) &&
            _hasDigit(p) &&
            _hasSpecial(p));
        if (mounted) {
          setState(() {
            _showPasswordRulesFailed = anyFailed;
          });
        }
      } else {
        // поле получило фокус — скрываем агрессивные подсказки
        if (mounted) {
          setState(() {
            _showPasswordRulesFailed = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // base sizes copied from sign-in code for consistent scaling
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

    final password = _passwordController.text;

    // password rule booleans (разделены)
    final okMin = _hasMinLength(password);
    final okUpper = _hasUppercase(password);
    final okLower = _hasLowercase(password);
    final okDigit = _hasDigit(password);
    final okSpecial = _hasSpecial(password);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4027, 0.9883],
                colors: [
                  Color(0xFFECFFDE),
                  Color(0xFFEEFFEF),
                ],
              ),
            ),
          ),

          // Message bubble "Создай свой аккаунт"
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
                    'Создай свой аккаунт',
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

          // Frog image
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

          // White sheet with form
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
                      'Регистрация',
                      style: TextStyle(
                        fontSize: 20 * ((scaleW + scaleH) / 2),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18 * scaleH),

                    // ФИО поля (Last, First, Middle)
                    _buildLabel('Фамилия', scaleW, scaleH, error: _lastNameError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _lastNameController,
                      hint: 'Введите фамилию',
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _lastNameError,
                      onChanged: (v) {
                        if (_lastNameError) setState(() => _lastNameError = false);
                        _onAnyFieldChanged();
                      },
                    ),

                    SizedBox(height: 12 * scaleH),
                    _buildLabel('Имя', scaleW, scaleH, error: _firstNameError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _firstNameController,
                      hint: 'Введите имя',
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _firstNameError,
                      onChanged: (v) {
                        if (_firstNameError) setState(() => _firstNameError = false);
                        _onAnyFieldChanged();
                      },
                    ),

                    SizedBox(height: 12 * scaleH),
                    _buildLabel('Отчество (необязательно)', scaleW, scaleH),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _middleNameController,
                      hint: 'Введите отчество',
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: false,
                      onChanged: (v) => _onAnyFieldChanged(),
                    ),

                    SizedBox(height: 12 * scaleH),
                    // Email
                    _buildLabel('Электронная почта', scaleW, scaleH, error: _emailError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _emailController,
                      hint: 'Введите вашу почту',
                      keyboardType: TextInputType.emailAddress,
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _emailError,
                      onChanged: (v) {
                        if (_emailError) setState(() => _emailError = false);
                        _onAnyFieldChanged();
                      },
                    ),

                    SizedBox(height: 12 * scaleH),
                    // Password
                    _buildLabel('Пароль', scaleW, scaleH, error: _passwordError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _passwordController,
                      hint: 'Введите пароль',
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          size: 20 * ((scaleW + scaleH) / 2),
                          color: _passwordError ? _dangerRed : Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _passwordError,
                      onChanged: (v) {
                        // при вводе — скрываем "красные" подсказки, т.к. пользователь продолжает ввод
                        if (_passwordError) setState(() => _passwordError = false);
                        if (_showPasswordRulesFailed) setState(() => _showPasswordRulesFailed = false);
                        _onAnyFieldChanged();
                      },
                      focusNode: _passwordFocusNode,
                    ),

                    SizedBox(height: 8 * scaleH),
                    // Password rules list (colored) — теперь с отдельными правилами для цифр и спецсимволов
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ruleRowWithFailureState(okMin, 'мин. 8 символов', scaleW, scaleH, failed: !okMin && _showPasswordRulesFailed),
                        _ruleRowWithFailureState(okUpper, 'мин. одна заглавная буква (A-Z)', scaleW, scaleH, failed: !okUpper && _showPasswordRulesFailed),
                        _ruleRowWithFailureState(okLower, 'мин. одна строчная буква (a-z)', scaleW, scaleH, failed: !okLower && _showPasswordRulesFailed),
                        _ruleRowWithFailureState(okDigit, 'мин. одна цифра (0-9)', scaleW, scaleH, failed: !okDigit && _showPasswordRulesFailed),
                        _ruleRowWithFailureState(okSpecial, 'мин. один спецсимвол (., _, -)', scaleW, scaleH, failed: !okSpecial && _showPasswordRulesFailed),
                      ],
                    ),

                    SizedBox(height: 12 * scaleH),
                    // Confirm password
                    _buildLabel('Подтверждение пароля', scaleW, scaleH, error: _confirmPasswordError),
                    SizedBox(height: 6 * scaleH),
                    _buildFilledField(
                      controller: _confirmPasswordController,
                      hint: 'Повторите пароль',
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          size: 20 * ((scaleW + scaleH) / 2),
                          color: _confirmPasswordError ? _dangerRed : Colors.grey[600],
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      height: 44 * scaleH,
                      scaleW: scaleW,
                      scaleH: scaleH,
                      hasError: _confirmPasswordError,
                      onChanged: (v) {
                        if (_confirmPasswordError) setState(() => _confirmPasswordError = false);
                        _onAnyFieldChanged();
                      },
                      focusNode: _confirmPasswordFocusNode,
                    ),

                    if (_confirmPasswordError)
                      Padding(
                        padding: EdgeInsets.only(top: 8.0 * scaleH, left: 4 * scaleW),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Пароли не совпадают',
                            style: TextStyle(
                              color: _dangerRed.withOpacity(0.9),
                              fontSize: 13 * ((scaleW + scaleH) / 2),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 12 * scaleH),
                    // Checkbox + terms
                    Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (v) => setState(() => _isChecked = v ?? false),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Нажимая на кнопку "Создать аккаунт", я принимаю ',
                              style: TextStyle(
                                color: const Color(0xFF777777),
                                fontSize: 12 * ((scaleW + scaleH) / 2),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Условия использования',
                                  style: TextStyle(
                                    color: _okGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => TermsOfServicePage()));
                                  },
                                ),
                                TextSpan(text: ' и '),
                                TextSpan(
                                  text: 'Политику конфиденциальности',
                                  style: TextStyle(
                                    color: _okGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPolicyPage()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12 * scaleH),
                    // CTA button (style like sign-in)
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onCreatePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormFilled ? _okGreen : _mutedGreen,
                          elevation: 5,
                          shadowColor: _okGreen.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(69 * ((scaleW + scaleH) / 2)),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20 * scaleW,
                          height: 20 * scaleW,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Создать аккаунт',
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
                    Text(
                      'Или войдите в аккаунт, используя\nодин из сервисов',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF777777).withOpacity(0.5),
                        fontSize: 13 * ((scaleW + scaleH) / 2),
                      ),
                    ),

                    SizedBox(height: 12 * scaleH),
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

          // bottom home indicator (like in sign-in)
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

  // small helper widgets (copied/adapted from your sign-in code)
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
    FocusNode? focusNode,
  }) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(101 * ((scaleW + scaleH) / 2)),
        border: hasError ? Border.all(color: const Color(0xFFFF4D4D), width: 1.5) : null,
      ),
      child: Center(
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          obscuringCharacter: '*',
          keyboardType: keyboardType,
          onChanged: (value) {
            if (onChanged != null) onChanged(value);
            setState(() {}); // refresh for button color / rules
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

  /// Новая версия строки правила, которая учитывает состояние "failed":
  /// - если ok == true -> зелёный
  /// - если ok == false && failed == true -> красный
  /// - иначе (ok == false && failed == false) -> нейтральный серый
  Widget _ruleRowWithFailureState(bool ok, String text, double scaleW, double scaleH, {bool failed = false}) {
    Color dotColor;
    Color textColor;

    if (ok) {
      dotColor = _okGreen;
      textColor = _okGreen;
    } else if (failed) {
      dotColor = _dangerRed;
      textColor = _dangerRed.withOpacity(0.95);
    } else {
      dotColor = Colors.grey.withOpacity(0.4);
      textColor = Colors.grey.withOpacity(0.6);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4.0 * scaleH),
      child: Row(
        children: [
          Container(
            width: 6 * ((scaleW + scaleH) / 2),
            height: 6 * ((scaleW + scaleH) / 2),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8 * scaleW),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13 * ((scaleW + scaleH) / 2),
            ),
          ),
        ],
      ),
    );
  }
}

// Маленький треугольник под "Создай свой аккаунт"
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

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path.shift(const Offset(0, 0.5)), shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//да