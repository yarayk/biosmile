import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Текущая вкладка "Упражнения"
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/work.png', width: 40, height: 40),
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
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...exerciseSections.map((section) {
              return GestureDetector(
                onTap: () async {
                  await _saveOpenedSection(section['title']!);
                  Navigator.pushNamed(context, section['route']!);
                },
                child: ExerciseSectionButton(imagePath: section['imagePath']!),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Виджет для кнопок разделов
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
