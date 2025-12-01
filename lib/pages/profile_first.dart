// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import '../profile_service.dart';
import 'progress_with_points.dart';
import 'package:untitled2/widget/tabbar.dart';


class ProfileFirst extends StatefulWidget {
  const ProfileFirst({Key? key}) : super(key: key);

  @override
  State<ProfileFirst> createState() => _ProfileFirstState();
}

class _ProfileFirstState extends State<ProfileFirst> {
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
    });

    final current = ModalRoute.of(context)?.settings.name;
    // Навигация только если маршрут отличается и зарегистрирован в MaterialApp
    if (current != routes[index]) {
      // Пытаемся безопасно перейти на маршрут
      try {
        Navigator.of(context).pushNamed(routes[index]);
      } catch (e) {
        // Если маршрут не зарегистрирован, ничего не ломаем
        // можно тут логировать ошибку в devMode
      }
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
        userName = profile.firstName.isNotEmpty ? profile.firstName : '${profile.firstName} ${profile.lastName}';
        userCoins = profile.coins;
        userXp = profile.xp;
        userLevel = profile.level;
        avatarUrl = (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) ? profile.avatarUrl : null;
      });
    }
  }

  double _clampedProgress() {
    // защищаем от деления на ноль и негативных значений
    final clampedXp = userXp.clamp(0, 100);
    return clampedXp / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // если хотите фон через картинку — можно разкомментировать ниже
      // body: Stack(children: [ Positioned.fill(child: Image.asset('assets/image/fon8.png', fit: BoxFit.cover)), buildContent() ]),
      body: SafeArea(child: buildContent()),
      bottomNavigationBar: MainTabBar(
        iconStates01: iconStates01,
        selectedIndex: selectedTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Прогресс
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProgressWithPoints(
              progress: _clampedProgress(),
              points: userCoins,
            ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

                // Аватар — показываем, только если avatarUrl не null
                if (avatarUrl != null)
                  Positioned(
                    bottom: -60,
                    right: 10,
                    child: SizedBox(
                      height: 240,
                      child: _buildAvatarWidget(avatarUrl!),
                    ),
                  )
                else
                // если аватара нет — показываем плавающий placeholder
                  const SizedBox(),

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

          const SizedBox(height: 80),

          // Фото-дневник (кнопка)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/photo_diary'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/image/photo_diary_button.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Сделать фото
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/photo'),
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
    );
  }

  Widget _buildAvatarWidget(String path) {
    // Если у вас avatarUrl — это локальный asset-путь, используем Image.asset,
    // если это URL интернета — используйте Image.network.
    // Здесь делаем attempt: сначала Asset, при ошибке — пробуем Network.
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Попытка как network
        return Image.network(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // последний fallback
            return CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 48, color: Colors.grey.shade400),
            );
          },
        );
      },
    );
  }
}
