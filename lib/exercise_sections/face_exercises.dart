import 'package:flutter/material.dart';
import '../pages/progress_with_points.dart';
import '../profile_service.dart';

class FaceExercisesPage extends StatefulWidget {
  @override
  _FaceExercisesPageState createState() => _FaceExercisesPageState();
}

class _FaceExercisesPageState extends State<FaceExercisesPage> {
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

  int userCoins = 0;
  int userXp = 0;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    List? states = await ProfileService().getStates();
    setState(() {
      userCoins = (states?[0] ?? 0) as int;
      userXp = (states?[1] ?? 0) as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // чтобы навигация была поверх фона

      body: Stack(
        children: [
          // Фон на весь экран
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon7.png',
              fit: BoxFit.cover,
            ),
          ),

          // Содержимое экрана с вертикальной прокруткой
          Column(
            children: [
              const SizedBox(height: 40), // безопасный отступ сверху

              // Прогресс-бар и очки с динамическими данными
              ProgressWithPoints(
                progress: (userXp / 100).clamp(0.0, 1.0),
                points: userCoins,
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
                        children: const [
                          Icon(Icons.arrow_back, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
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

              // Список упражнений, расширяемый с прокруткой
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
                            color: const Color(0xFFFFEB3B),
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
        ],
      ),

      // Нижняя навигация с прозрачным фоном
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.transparent, // <== если нужно полупрозрачное
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
