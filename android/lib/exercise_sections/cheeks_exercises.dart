import 'package:flutter/material.dart';
import '../pages/progress_with_points.dart';

class CheeksExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'title': '1. Надуть обе щеки', 'route': '/cheeks_1'},
    {'title': '2. Втянуть щеки', 'route': '/cheeks_2'},
    {'title': '3. Надуть правую щеку, затем левую', 'route': '/cheeks_3'},
    {'title': '4. Чередовать 1 и 2', 'route': '/cheeks_4'},
    {'title': '5. Имитировать полоскание', 'route': '/cheeks_5'},
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
                        'Упражнения для щёк',
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
                        color: 	Color(0xFF8BC34A),
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
