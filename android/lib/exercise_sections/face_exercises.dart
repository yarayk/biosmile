import 'package:flutter/material.dart';
import '../pages/progress_with_points.dart';

class FaceExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'title': '1. Поднять брови вверх, удержать', 'route': '/face_1'},
    {'title': '2. Нахмурить брови, удержать', 'route': '/face_2'},
    {'title': '3. Закрыть глаза (крепко–слабо)', 'route': '/face_3'},
    {'title': '4. Поморгать', 'route': '/face_4'},
    {'title': '5. Двигать глазным яблоком, закрыв глаза', 'route': '/face_5'},
    {'title': '6. Прищуриваться, подтягивая нижнее веко', 'route': '/face_6'},
    {'title': '7. Поочередно закрывать правый и левый глаз', 'route': '/face_7'},
    {'title': '8. Сморщить нос', 'route': '/additional_8'},
    {'title': '9. Раздувать ноздри, шевелить носом. Втягивать ноздри', 'route': '/face_9'},
    {'title': '10. Звук “М”', 'route': '/face_10'},
    {'title': '11. Звук “О”', 'route': '/face_11'},
    {'title': '12. Плевать', 'route': '/face_12'},
    {'title': '13. Звуки “У”, “А”', 'route': '/face_13'},
    {'title': '14. Рот открыт, звуки “О”, “А”', 'route': '/face_14'},
    {'title': '15. Произносить “Т”, “П”, “Р”, “У”', 'route': '/face_15'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40), // Safe area top

          //прогресс бар и очки
          ProgressWithPoints(
            progress: 0.56,
            points: 1000, // можно подставить значение из переменной
          ),
          const SizedBox(height: 20),

          // Кнопка "назад" с текстом
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.blue),
                      const SizedBox(width: 4),
                      const Text(
                        'Упражнения для мимических мышц',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Список упражнений
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, exercise['route']!),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEB3B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              exercise['title']!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Image.asset(
                            'assets/image/play_button.png',
                            width: 36,
                            height: 36,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),

      // Нижняя панель навигации
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
    );
  }
}
