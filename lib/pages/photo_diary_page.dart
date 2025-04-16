import 'package:flutter/material.dart';

class PhotoDiaryPage extends StatelessWidget {
  const PhotoDiaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/work.png', width: 30, height: 30),
            label: 'Упражнения',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/home.png', width: 30, height: 30),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/prof.png', width: 30, height: 30),
            label: 'Профиль',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/exercise_sections');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Здесь будут располагаться ваши фотографии для отслеживания прогресса.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
