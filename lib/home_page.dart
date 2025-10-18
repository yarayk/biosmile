import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile_service.dart';
import 'pages/progress_with_points.dart';
import '../achievement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> openedSections = [];
  String userName = '...'; // Имя пользователя
  int userCoins = 0; // Инициализация значений по умолчанию
  int userXp = 0;
  int userLevel = 0;

  // Функция для подгрузки имени пользователя
  Future<void> _loadUserName() async {
    String? name = await ProfileService().getFirstName();
    setState(() {
      // Убираем fallback на "Гость" — если имя не загрузилось, показываем "..."
      userName = name ?? 'Пользователь';
    });
  }

  Future<void> _loadStates() async {
    List? states = await ProfileService().getStates();
    setState(() {
      userCoins = (states?[0] ?? 0) as int;
      userXp = (states?[1] ?? 0) as int;
      userLevel = (states?[2] ?? 0) as int;
    });
  }

  final List<Map<String, String>> exerciseSections = [
    {'title': 'Упражнения для мимических мышц', 'imagePath': 'assets/image/exercise_face.png', 'route': '/face_exercises'},
    {'title': 'Упражнения для щек', 'imagePath': 'assets/image/exercise_cheeks.png', 'route': '/cheeks_exercises'},
    {'title': 'Упражнения для нижней челюсти', 'imagePath': 'assets/image/exercise_jaw.png', 'route': '/jaw_exercises'},
    {'title': 'Упражнения для губ', 'imagePath': 'assets/image/exercise_lips.png', 'route': '/lips_exercises'},
    {'title': 'Упражнения для языка', 'imagePath': 'assets/image/exercise_tongue.png', 'route': '/tongue_exercises'},
    {'title': 'Дополнительные упражнения', 'imagePath': 'assets/image/exercise_additional.png', 'route': '/additional_exercises'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthAndInitialize();
  }

  /// ГЛАВНАЯ ПРОВЕРКА: если пользователь не авторизован, выкидываем на страницу входа
  Future<void> _checkAuthAndInitialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    final session = Supabase.instance.client.auth.currentSession;

    // Если нет пользователя ИЛИ нет сессии — значит, пользователь НЕ авторизован
    if (user == null || session == null) {
      // Перенаправляем на страницу входа
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    // Если пользователь авторизован — загружаем данные
    await _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadUserName();
    await _loadStates();
    await _loadOpenedSections();

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await AchievementService().checkAndAwardAchievements(context, userId);
    }
  }

  Future<void> _loadOpenedSections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> openedTitles = prefs.getStringList('opened_sections') ?? [];

    if (openedTitles.length > 2) {
      openedTitles = openedTitles.sublist(openedTitles.length - 2);
      await prefs.setStringList('opened_sections', openedTitles);
    }

    setState(() {
      openedSections = exerciseSections
          .where((section) => openedTitles.contains(section['title']))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Фон на ВСЮ страницу
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Содержимое с прокруткой
          Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Привет, $userName!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ProgressWithPoints(
                progress: userXp / 100,
                points: userCoins,
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: const Color.fromARGB(51, 200, 200, 200),
                        blurRadius: 5,
                        spreadRadius: 2),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/image/cat1.png', width: 80, height: 80),
                    Image.asset('assets/image/10.png', width: 120, height: 120),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: openedSections.map((section) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, section['route']!);
                        },
                        child:
                        ExerciseSectionButton(imagePath: section['imagePath']!),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Навигация поверх фона
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.transparent,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/work.png', width: 30, height: 30),
            label: 'Упражнения',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/image/home.png', width: 40, height: 40),
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
