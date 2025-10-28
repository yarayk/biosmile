import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Реальный сервис смены пароля через Supabase
class AuthService {
  static Future<String?> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Быстрая валидация совпадения
    if (newPassword != confirmPassword) return 'Пароли не совпадают';

    final supabase = Supabase.instance.client;

    // Сессия должна быть установлена после перехода по ссылке восстановления
    // Если её нет — попросим открыть ссылку из письма снова
    if (supabase.auth.currentSession == null) {
      return 'Сессия не найдена. Откройте ссылку из письма ещё раз.';
    }

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Ошибка при обновлении пароля: $e';
    }
  }
}

// Треугольник под облаком
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

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  final FocusNode _newPassFocusNode = FocusNode();
  final FocusNode _confirmPassFocusNode = FocusNode();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _newPassError = false;
  bool _confirmPassError = false;
  bool _showPasswordRulesFailed = false;

  static const Color _okGreen = Color(0xFF81C784);
  static const Color _mutedGreen = Color(0xFFC0E3C2);
  static const Color _dangerRed = Color(0xFFFF4D4D);

  bool _hasMinLength(String p) => p.length >= 8;
  bool _hasUppercase(String p) => p.contains(RegExp(r'[A-ZА-Я]'));
  bool _hasLowercase(String p) => p.contains(RegExp(r'[a-zа-я]'));
  bool _hasDigit(String p) => p.contains(RegExp(r'\d'));
  bool _hasSpecial(String p) => p.contains(RegExp(r'[._\-]'));

  bool get _isFormFilled =>
      _newPassController.text.isNotEmpty && _confirmPassController.text.isNotEmpty;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onAnyFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _newPassFocusNode.addListener(() {
      if (!_newPassFocusNode.hasFocus) {
        final p = _newPassController.text;
        final anyFailed = !(_hasMinLength(p) &&
            _hasUppercase(p) &&
            _hasLowercase(p) &&
            _hasDigit(p) &&
            _hasSpecial(p));
        if (mounted) setState(() => _showPasswordRulesFailed = anyFailed);
      } else {
        if (mounted) setState(() => _showPasswordRulesFailed = false);
      }
    });
  }

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    _newPassFocusNode.dispose();
    _confirmPassFocusNode.dispose();
    super.dispose();
  }

  Widget _ruleRowWithFailureState(bool ok, String text, double scaleW, double scaleH, {bool failed = false}) {
    Color dotColor, textColor;
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
    final frogTop = 151.0 * scaleH;
    final msgW = 232.0 * scaleW;
    final msgH = 56.0 * scaleH;
    final msgTop = 74.0 * scaleH;
    final sheetHeight = 346.0 * scaleH;
    final buttonHeight = 51.0 * scaleH;

    final password = _newPassController.text;
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

          // Облако подсказки
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
                    'Отлично! Введи новый\nпароль',
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

          // Белый лист с формой
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
                    Text(
                      'Сменить пароль',
                      style: TextStyle(
                        fontSize: 20 * ((scaleW + scaleH) / 2),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18 * scaleH),

                    // Новый пароль
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Новый пароль*',
                        style: TextStyle(
                          color: _newPassError ? _dangerRed : const Color(0xFF777777),
                          fontSize: 14 * ((scaleW + scaleH) / 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * scaleH),
                    Container(
                      height: 44 * scaleH,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(101 * ((scaleW + scaleH) / 2)),
                        border: _newPassError
                            ? Border.all(color: _dangerRed, width: 1.5)
                            : null,
                      ),
                      child: TextField(
                        focusNode: _newPassFocusNode,
                        controller: _newPassController,
                        obscureText: _obscureNew,
                        obscuringCharacter: '*',
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 14 * ((scaleW + scaleH) / 2),
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Введите новый пароль',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[600],
                              size: 20 * ((scaleW + scaleH) / 2),
                            ),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                        onChanged: (v) {
                          if (_newPassError) setState(() => _newPassError = false);
                          if (_showPasswordRulesFailed) setState(() => _showPasswordRulesFailed = false);
                          _onAnyFieldChanged();
                        },
                      ),
                    ),

                    SizedBox(height: 8 * scaleH),
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

                    // Повторите пароль
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Повторите пароль*',
                        style: TextStyle(
                          color: _confirmPassError ? _dangerRed : const Color(0xFF777777),
                          fontSize: 14 * ((scaleW + scaleH) / 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * scaleH),
                    Container(
                      height: 44 * scaleH,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(101 * ((scaleW + scaleH) / 2)),
                        border: _confirmPassError
                            ? Border.all(color: _dangerRed, width: 1.5)
                            : null,
                      ),
                      child: TextField(
                        focusNode: _confirmPassFocusNode,
                        controller: _confirmPassController,
                        obscureText: _obscureConfirm,
                        obscuringCharacter: '*',
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 14 * ((scaleW + scaleH) / 2),
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Повторите пароль',
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[600],
                              size: 20 * ((scaleW + scaleH) / 2),
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                        onChanged: (v) {
                          if (_confirmPassError) setState(() => _confirmPassError = false);
                          _onAnyFieldChanged();
                        },
                      ),
                    ),
                    if (_confirmPassError)
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

                    SizedBox(height: 18 * scaleH),

                    // Кнопка сохранить
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          setState(() {
                            _newPassError = false;
                            _confirmPassError = false;
                          });

                          final newPassword = _newPassController.text;
                          final confirmPassword = _confirmPassController.text;

                          // Локальная валидация по правилам интерфейса
                          final anyRuleFailed = !_hasMinLength(newPassword) ||
                              !_hasUppercase(newPassword) ||
                              !_hasLowercase(newPassword) ||
                              !_hasDigit(newPassword) ||
                              !_hasSpecial(newPassword);

                          if (anyRuleFailed) {
                            setState(() {
                              _newPassError = true;
                              _showPasswordRulesFailed = true;
                            });
                            _showError(
                              'Пароль должен содержать:\n- мин. 8 символов\n- одну заглавную и одну строчную букву\n- одну цифру\n- один спецсимвол (., _, -)',
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            setState(() => _confirmPassError = true);
                            _showError('Пароли не совпадают');
                            return;
                          }

                          setState(() => _isLoading = true);
                          final errorMessage = await AuthService.changePassword(
                            newPassword: newPassword,
                            confirmPassword: confirmPassword,
                          );
                          setState(() => _isLoading = false);

                          if (errorMessage != null) {
                            _showError(errorMessage);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Пароль успешно обновлён')),
                            );
                            if (mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          }
                        },
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
                          'Сохранить пароль',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
