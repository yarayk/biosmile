import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';

class AuthSignUpWidget extends StatefulWidget {
  @override
  _AuthSignUpWidgetState createState() => _AuthSignUpWidgetState();
}

class _AuthSignUpWidgetState extends State<AuthSignUpWidget> {
  bool _isChecked = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[._-])[A-Za-z\d._-]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s-]+$'); // Разрешаем буквы, пробелы и дефисы
    return nameRegex.hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Создайте аккаунт',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            // Фамилия
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Фамилия *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Имя
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Имя *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Отчество
            TextField(
              controller: _middleNameController,
              decoration: InputDecoration(
                labelText: 'Отчество',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Почта
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Электронная почта *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Пароль
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Пароль *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 12),
            // Подтверждение пароля
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Я прочитал(а) ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Условия использования',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TermsOfServicePage(),
                                ),
                              );
                            },
                        ),
                        TextSpan(text: ' и '),
                        TextSpan(
                          text: 'Политику конфиденциальности',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                final password = _passwordController.text;
                final confirmPassword = _confirmPasswordController.text;
                final lastName = _lastNameController.text.trim();
                final firstName = _firstNameController.text.trim();
                final middleName = _middleNameController.text.trim();

                // Проверка фамилии
                if (lastName.isEmpty) {
                  _showError('Пожалуйста, введите фамилию');
                  return;
                }
                if (!_isValidName(lastName)) {
                  _showError('Фамилия может содержать только буквы, пробелы и дефисы');
                  return;
                }

                // Проверка имени
                if (firstName.isEmpty) {
                  _showError('Пожалуйста, введите имя');
                  return;
                }
                if (!_isValidName(firstName)) {
                  _showError('Имя может содержать только буквы, пробелы и дефисы');
                  return;
                }

                // Проверка отчества (если заполнено)
                if (middleName.isNotEmpty && !_isValidName(middleName)) {
                  _showError('Отчество может содержать только буквы, пробелы и дефисы');
                  return;
                }

                // Проверка email
                if (!_isValidEmail(email)) {
                  _showError('Пожалуйста, введите корректный email');
                  return;
                }

                // Проверка пароля
                if (password.length < 8) {
                  _showError('Пароль должен содержать минимум 8 символов');
                  return;
                }
                if (!_isValidPassword(password)) {
                  _showError('Пароль должен содержать:\n'
                      '- 1 заглавную букву\n'
                      '- 1 цифру\n'
                      '- 1 специальный символ ( . _ - )');
                  return;
                }
                if (password != confirmPassword) {
                  _showError('Пароли не совпадают');
                  return;
                }

                // Проверка принятия условий
                if (!_isChecked) {
                  _showError('Пожалуйста, примите условия использования');
                  return;
                }

                // Если все проверки пройдены
                Navigator.pushNamed(context, '/email-verification');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'СОЗДАТЬ АККАУНТ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text('ИЛИ', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Image.asset('assets/image/google_logo.png', height: 24),
              label: Text(
                'ВОЙТИ С GOOGLE',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text.rich(
                TextSpan(
                  text: 'У вас уже есть аккаунт? ',
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'ВОЙТИ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}