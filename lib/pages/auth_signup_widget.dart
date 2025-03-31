import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';

class AuthSignUpWidget extends StatefulWidget {
  @override
  _AuthSignUpWidgetState createState() => _AuthSignUpWidgetState();
}

//Контроллеры
class _AuthSignUpWidgetState extends State<AuthSignUpWidget> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
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
            // Электронная почта
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
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
            SizedBox(height: 24),
            // Чекбокс с условиями
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
            // Кнопка регистрации
            ElevatedButton(
              onPressed: _signUp,
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
              onPressed: _signInWithGoogle,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Image.asset('assets/google_logo.png', height: 24),
              label: Text(
                'ВОЙТИ С GOOGLE',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
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

  // Функция регистрации
  Future<void> _signUp() async {
    final lastName = _lastNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final middleName = _middleNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (lastName.isEmpty || firstName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация прошла успешно!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка при регистрации')),
        );
      }
    } catch (e) {
      print('Error during sign up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла ошибка при регистрации')),
      );
    }
  }

  // Функция входа через Google
  Future<void> _signInWithGoogle() async {
    try {
      // Вход через Google
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google, // Используем OAuthProvider.google
      );

      // Проверка успешного ответа
      if (response == true) {
        // Если возвращается true, то авторизация успешна
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешный вход через Google')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Если возвращается false или ошибка
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа: Неизвестная ошибка')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e')),
      );
    }
  }
  // Проверка, авторизован ли пользователь
  void _checkUserSession() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }
}
