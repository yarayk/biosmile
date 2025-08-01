import 'package:flutter/material.dart';
import '../pages/progress_with_points.dart';
import '../profile_service.dart';

class CheeksExercisesPage extends StatefulWidget {
  @override
  _CheeksExercisesPageState createState() => _CheeksExercisesPageState();
}

class _CheeksExercisesPageState extends State<CheeksExercisesPage> {
  final List<Map<String, String>> exercises = [
    {'title': '1. Надуть обе щеки', 'route': '/cheeks_1'},
    {'title': '2. Втянуть щеки', 'route': '/cheeks_2'},
    {'title': '3. Надуть правую щеку, затем левую', 'route': '/cheeks_3'},
    {'title': '4. Чередовать 1 и 2', 'route': '/cheeks_4'},
    {'title': '5. Имитировать полоскание', 'route': '/cheeks_5'},
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
              'assets/image/fon2.png',
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

              // Список упражнений с прокруткой
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
                            color: const Color(0xFF8BC34A),
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
        backgroundColor: Colors.transparent,
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

