import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Лягушка
            Image.asset(
              'assets/newimage/frog.png',
              width: 150, // ширина картинки лягушки
              height: 150, // высота картинки лягушки
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 2), // отступ между лягушкой и "Привет!"

            // Приветствие
            const Text(
              'Привет!',
              style: TextStyle(
                fontSize: 24, // размер шрифта "Привет!"
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4), // отступ между "Привет!" и подзаголовком
            const Text(
              'Давай познакомимся',
              style: TextStyle(
                fontSize: 16, // размер подзаголовка
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 60), // отступ между надписью и кнопками

            // Кнопка "Создать аккаунт" (как картинка)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Image.asset(
                'assets/newimage/signup_button.png',
                fit: BoxFit.contain,
                // width: 250, // ширина кнопки
                // height: 60,  // высота кнопки
              ),
            ),

            const SizedBox(height: 0), // ✅ отступ между кнопками

            // Кнопка "Войти" (как картинка)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: Image.asset(
                'assets/newimage/login_button.png',
                fit: BoxFit.contain,
                // width: 250, // ширина кнопки
                // height: 60,  // высота кнопки
              ),
            ),

            const SizedBox(height: 30), // отступ между кнопками и иконками

            // Иконки (Google, Apple, Госуслуги)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/newimage/google.png',
                  width: 40, // размер иконки Google
                  height: 40,
                ),
                const SizedBox(width: 20), // отступ между иконками
                Image.asset(
                  'assets/newimage/apple.png',
                  width: 40, // размер иконки Apple
                  height: 40,
                ),
                const SizedBox(width: 20), // отступ между иконками
                Image.asset(
                  'assets/newimage/gosuslugi.png',
                  width: 40, // размер иконки Госуслуги
                  height: 40,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
