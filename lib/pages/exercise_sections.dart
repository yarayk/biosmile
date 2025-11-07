import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_service.dart';
import 'progress_with_points.dart';
import 'package:untitled2/widget/tabbar.dart';

class ExerciseSectionsPage extends StatefulWidget {
  const ExerciseSectionsPage({Key? key}) : super(key: key);

  @override
  State<ExerciseSectionsPage> createState() => _ExerciseSectionsPageState();
}

class _ExerciseSectionsPageState extends State<ExerciseSectionsPage> {
  final List<Map<String, String>> exerciseSections = [
    {
      'title': 'Упражнения для мимических мышц',
      'imagePath': 'assets/image/exercise_face.png',
      'route': '/face_exercises'
    },
    {
      'title': 'Упражнения для щек',
      'imagePath': 'assets/image/exercise_cheeks.png',
      'route': '/cheeks_exercises'
    },
    {
      'title': 'Упражнения для нижней челюсти',
      'imagePath': 'assets/image/exercise_jaw.png',
      'route': '/jaw_exercises'
    },
    {
      'title': 'Упражнения для губ',
      'imagePath': 'assets/image/exercise_lips.png',
      'route': '/lips_exercises'
    },
    {
      'title': 'Упражнения для языка',
      'imagePath': 'assets/image/exercise_tongue.png',
      'route': '/tongue_exercises'
    },
    {
      'title': 'дополнительные упражнения',
      'imagePath': 'assets/image/exercise_additional.png',
      'route': '/additional_exercises'
    },
  ];

  int userCoins = 0;
  int userXp = 0;
  int userLevel = 0;

  // Индекс "Упражнения" во втором положении
  int selectedTabIndex = 1;

  // Маршруты для табов соответствуют порядку MainTabBar
  final List<String> routes = [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile',
  ];

  // Массив фиксированных состояний иконок таббара (можно менять!)
  // Пример: подсвечиваем только "Упражнения"
  List<int> iconStates01 = [0, 1, 0, 0];

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
    final prefs = await SharedPreferences.getInstance();
    final openedSections = prefs.getStringList('opened_sections') ?? [];
    if (!openedSections.contains(sectionTitle)) {
      openedSections.add(sectionTitle);
      await prefs.setStringList('opened_sections', openedSections);
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
      // Можем менять иконки динамически при клике, если нужно:
      // iconStates01 = List.generate(4, (i) => i == index ? 1 : 0);
    });
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != routes[index]) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
                        child: ExerciseSectionButton(
                          imagePath: section['imagePath']!,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: MainTabBar(
        // Подсветкой иконок управляет iconStates01!
        iconStates01: iconStates01,
        selectedIndex: selectedTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class ExerciseSectionButton extends StatelessWidget {
  final String imagePath;

  const ExerciseSectionButton({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
