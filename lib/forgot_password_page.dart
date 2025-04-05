import 'package:flutter/material.dart';
import 'verification_code_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Забыли пароль')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Введите свою электронную почту', style: TextStyle(fontSize: 22)),
            SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Электронная почта',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Проверка почты
                if (emailController.text.isEmpty || !emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный адрес электронной почты')));
                  return;
                }
                Navigator.pushNamed(context, '/verification-code');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('ПРОДОЛЖИТЬ', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
