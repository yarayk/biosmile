import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../profile_service.dart';
import 'progress_with_points.dart';
import 'package:untitled2/widget/tabbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru', 'RU'),
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Таббар: та же конфигурация, что и в HomePage
  int selectedTabIndex = 3; // 0:/home, 1:/exercise_sections, 2:/photo_diary, 3:/profile
  final List<String> routes = const [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile_first',
  ];

  List<int> iconStates01 = [0, 0, 0, 1];

  void _onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
      // Можно сделать динамическую подсветку так:
      // iconStates01 = List.generate(4, (i) => i == index ? 1 : 0);
    });
    final current = ModalRoute.of(context)?.settings.name;
    if (current != routes[index]) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String userName = '...';
  int userCoins = 0;
  int userXp = 0;
  int userLevel = 0;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService().loadProfileWithAvatar();
    if (profile != null) {
      setState(() {
        userName = profile.firstName;
        userCoins = profile.coins;
        userXp = profile.xp;
        userLevel = profile.level;
        avatarUrl = profile.avatarUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // фон и контент оставлены без изменений
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon8.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Прогресс
                      ProgressWithPoints(
                        progress: userXp / 100,
                        points: userCoins,
                      ),
                      const SizedBox(height: 20),

                      // Карточка профиля
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.yellow[700],
                                image: const DecorationImage(
                                  image: AssetImage('assets/image/yellow_bg.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Уровень $userLevel',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Аватар
                            if (avatarUrl != null)
                              Positioned(
                                bottom: -60,
                                right: 10,
                                child: Image.asset(
                                  avatarUrl!,
                                  height: 240,
                                ),
                              ),

                            // Иконка настроек
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              ),
                            ),

                            // Кнопка "Зал славы"
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/hall');
                                },
                                child: Image.asset(
                                  'assets/image/in_hall.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Фото-дневник
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/photo_diary');
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/image/photo_diary_button.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Кнопка "Сделать фото"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/photo');
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/image/sdelat_photo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Календарь
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.amber.shade200, width: 2),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: TableCalendar(
                            locale: 'ru_RU',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.lightGreen.shade200,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: const TextStyle(color: Colors.white),
                              todayTextStyle: const TextStyle(color: Colors.white),
                              weekendTextStyle: const TextStyle(color: Colors.grey),
                              defaultTextStyle: TextStyle(color: Colors.grey.shade700),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              weekendStyle: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.orange),
                              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.orange),
                              formatButtonVisible: false,
                            ),
                            startingDayOfWeek: StartingDayOfWeek.monday,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Единый таббар как на главной
      bottomNavigationBar: MainTabBar(
        iconStates01: iconStates01,
        selectedIndex: selectedTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
