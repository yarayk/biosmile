import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Назад и заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back, color: Color(0xFF3C3C50)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Смена пароля',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C3C50),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Картинка
            Image.asset(
              'assets/image/resetpassword.png',
              width: 180,
              height: 180,
            ),

            const SizedBox(height: 32),

            // Текст
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Письмо с инструкциями отправлено на ваш email, проверьте почту',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF3C3C50),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Кнопка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF79E1B), // Ярко-оранжевая кнопка
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text(
                    'СТРАНИЦА АВТОРИЗАЦИИ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
