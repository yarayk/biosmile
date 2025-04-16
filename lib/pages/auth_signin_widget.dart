import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'auth_signup_widget.dart';
import '../auth_service.dart';

class AuthSignInWidget extends StatefulWidget {
  @override
  _AuthSignInWidgetState createState() => _AuthSignInWidgetState();
}

class _AuthSignInWidgetState extends State<AuthSignInWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              'Войдите в аккаунт',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Электронная почта',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                // Проверка email
                if (email.isEmpty) {
                  _showError('Пожалуйста, введите email');
                  return;
                }
                if (!_isValidEmail(email)) {
                  _showError('Пожалуйста, введите корректный email');
                  return;
                }

                // Проверка пароля
                if (password.isEmpty) {
                  _showError('Пожалуйста, введите пароль');
                  return;
                }

                 // ВЫЗОВ АВТОРИЗАЦИИ из auth_service.dart
                AuthService.signInWithEmail(
                  context: context,
                  email: email,
                  password: password,
                );
                // Если все проверки пройдены
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ВОЙТИ В АККАУНТ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text('или', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                AuthService.signInWithGoogle(context);
              },
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
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text.rich(
                TextSpan(
                  text: 'Еще нет аккаунта? ',
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'СОЗДАТЬ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forgot-password');
              },
              child: Text(
                'Забыли пароль?',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
