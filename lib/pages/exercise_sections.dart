import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_service.dart'; // Убедись, что этот импорт есть
import 'progress_with_points.dart';

class ExerciseSectionsPage extends StatefulWidget {
  @override
  _ExerciseSectionsPageState createState() => _ExerciseSectionsPageState();
}

class _ExerciseSectionsPageState extends State<ExerciseSectionsPage> {
  List<Map<String, String>> exerciseSections = [
    {'title': 'Упражнения для мимических мышц', 'imagePath': 'assets/image/exercise_face.png', 'route': '/face_exercises'},
    {'title': 'Упражнения для щек', 'imagePath': 'assets/image/exercise_cheeks.png', 'route': '/cheeks_exercises'},
    {'title': 'Упражнения для нижней челюсти', 'imagePath': 'assets/image/exercise_jaw.png', 'route': '/jaw_exercises'},
    {'title': 'Упражнения для губ', 'imagePath': 'assets/image/exercise_lips.png', 'route': '/lips_exercises'},
    {'title': 'Упражнения для языка', 'imagePath': 'assets/image/exercise_tongue.png', 'route': '/tongue_exercises'},
    {'title': 'дополнительные упражнения', 'imagePath': 'assets/image/exercise_additional.png', 'route': '/additional_exercises'},
  ];

  int userCoins = 0;
  int userXp = 0;
  int userLevel = 0;

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
      userLevel = (states?[2] ?? 0) as int;
    });
  }

  Future<void> _saveOpenedSection(String sectionTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> openedSections = prefs.getStringList('opened_sections') ?? [];

    if (!openedSections.contains(sectionTitle)) {
      openedSections.add(sectionTitle);
      await prefs.setStringList('opened_sections', openedSections);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // важно, чтобы фон был под навигацией
      body: Stack(
        children: [
          // Фоновое изображение
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon3.png',
              fit: BoxFit.cover,
            ),
          ),


          // Основное содержимое
          Column(
            children: [
              const SizedBox(height: 40),
              ProgressWithPoints(
                progress: userXp / 100,
                points: userCoins,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: exerciseSections.map((section) {
                      return GestureDetector(
                        onTap: () async {
                          await _saveOpenedSection(section['title']!);
                          Navigator.pushNamed(context, section['route']!);
                        },
                        child: ExerciseSectionButton(imagePath: section['imagePath']!),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Навигационная панель
              BottomNavigationBar(
                currentIndex: 0,
                backgroundColor: Colors.transparent, // прозрачный фон
                // elevation: 0, // можно убрать или оставить
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset('assets/image/work.png', width: 40, height: 40), // совпадает с первым кодом
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
            ],
          ),
        ],
      ),
    );
  }


}

class ExerciseSectionButton extends StatelessWidget {
  final String imagePath;

  const ExerciseSectionButton({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
