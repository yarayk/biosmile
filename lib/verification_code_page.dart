import 'package:flutter/material.dart';
import 'reset_password_page.dart';

class VerificationCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Введите код')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Введите код, отправленный на вашу почту', style: TextStyle(fontSize: 22)),
            SizedBox(height: 24),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Код из почты',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Проверка кода
                if (codeController.text.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный код')));
                  return;
                }
                Navigator.pushNamed(context, '/reset-password');
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
