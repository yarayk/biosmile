import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../profile_service.dart';
import 'progress_with_points.dart';

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
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String userName = '...';
  int userCoins = 0;
  int userXp = 0;
  int userLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadStates();
  }

  //Функция для подгрузки имени пользователя
  Future<void> _loadUserName() async {
    String? name = await ProfileService().getFirstName();
    setState(() {
      userName = name ?? 'Гость';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фон
          Positioned.fill(
            child: Image.asset(
              'assets/image/fon8.png',
              fit: BoxFit.cover,
            ),
          ),

          // Основное содержимое
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

                      // Жёлтая карточка профиля
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Stack(
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
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Уровень $userLevel',
                                          style: TextStyle(
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
                            Positioned(
                              bottom: 10,
                              right: 20,
                              child: Image.asset(
                                'assets/image/yelowcat.png',
                                height: 160,
                              ),
                            ),
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

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
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/photo');
                            },
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'Сделать фото',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
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
                              selectedDecoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: TextStyle(color: Colors.white),
                              todayTextStyle: TextStyle(color: Colors.white),
                              weekendTextStyle: TextStyle(color: Colors.grey),
                              defaultTextStyle: TextStyle(color: Colors.grey.shade700),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              weekendStyle: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            headerStyle: HeaderStyle(
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

              // Навигационная панель
              BottomNavigationBar(
                currentIndex: 2,
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
                    icon: Image.asset('assets/image/prof.png', width: 40, height: 40),
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
