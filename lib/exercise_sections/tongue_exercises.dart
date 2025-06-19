import 'package:flutter/material.dart';
import '../pages/progress_with_points.dart';
import '../profile_service.dart';  // обязательно добавь сервис

class TongueExercisesPage extends StatefulWidget {
  @override
  _TongueExercisesPageState createState() => _TongueExercisesPageState();
}

class _TongueExercisesPageState extends State<TongueExercisesPage> {
  final List<Map<String, String>> exercises = [
    {'title': '1. Открыть рот, язык поднять, опустить', 'route': '/tongue_1'},
    {'title': '2. Рот открыт, язык вверх-вниз', 'route': '/tongue_2'},
    {'title': '3. Рот открыть, язык к правому уху, к левому', 'route': '/tongue_3'},
    {'title': '4. Облизать нижнюю, затем верхнюю губу', 'route': '/tongue_4'},
    {'title': '5. Облизать губы по кругу', 'route': '/tongue_5'},
    {'title': '6. Языком погладить твердое небо', 'route': '/tongue_6'},
    {'title': '7. Длинное задание', 'route': '/tongue_7'},
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
      extendBody: true,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon3.png',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 40),

              ProgressWithPoints(
                progress: (userXp / 100).clamp(0.0, 1.0),
                points: userCoins,
              ),

              const SizedBox(height: 20),

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
                            'Упражнения для языка',
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
                            color: const Color(0xFF81D4FA),
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
