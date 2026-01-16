// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile_service.dart';
import 'package:untitled2/widget/tabbar.dart';
import 'package:untitled2/widget/exercise_top_bar.dart';

class ProfileFirst extends StatefulWidget {
  const ProfileFirst({Key? key}) : super(key: key);

  @override
  State<ProfileFirst> createState() => _ProfileFirstState();
}

class _ProfileFirstState extends State<ProfileFirst> {
  // Assets
  static const String _coinAsset = 'assets/newimage/coin_20.png';
  static const String _frogAvatarAsset = 'assets/newimage/frog1.png';
  static const String _frogMakePhotoAsset = 'assets/newimage/frog2.png';
  static const String _bookDiaryAsset = 'assets/newimage/book1.png';

  // Tabbar
  int selectedTabIndex = 3;
  final List<String> routes = const [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile_first',
  ];
  final List<int> iconStates01 = [0, 0, 0, 1];

  void _onTabSelected(int index) {
    setState(() => selectedTabIndex = index);

    final current = ModalRoute.of(context)?.settings.name;
    if (current != routes[index]) {
      try {
        Navigator.of(context).pushNamed(routes[index]);
      } catch (_) {}
    }
  }

  // Data
  String firstName = '';
  String lastName = '';
  String petAge = '';
  String petName = '';

  int userCoins = 0;
  int userXp = 0;
  int userLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileAndPetData();
  }

  Future<void> _loadProfileAndPetData() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await ProfileService().loadProfileWithAvatar();

    final loadedPetName = prefs.getString('petName') ?? '';
    final loadedPetAge = prefs.getString('petAge') ?? '';

    if (!mounted) return;

    setState(() {
      petName = loadedPetName;
      petAge = loadedPetAge;

      if (profile != null) {
        firstName = profile.firstName;
        lastName = profile.lastName;

        userCoins = profile.coins;
        userXp = profile.xp;
        userLevel = profile.level;
      }
    });
  }

  double _s(BuildContext context) => MediaQuery.of(context).size.width / 375.0;

  String _ageText() {
    final a = petAge.trim();
    if (a.isEmpty) return '';
    final onlyDigits = RegExp(r'^\d+$').hasMatch(a);
    if (onlyDigits) return '$a года';
    return a;
  }

  @override
  Widget build(BuildContext context) {
    final s = _s(context);
    const int nextXp = 200;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 0),
            ExerciseTopBar(
              coins: userCoins,
              currentXp: userXp,
              nextXp: nextXp,
            ),
            SizedBox(height: 26 * s),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context),
                      SizedBox(height: 16 * s),
                      _buildActionsRow(context),
                      SizedBox(height: 16 * s),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainTabBar(
        iconStates01: iconStates01,
        selectedIndex: selectedTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  BoxDecoration _cardDecoration(double s) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26 * s),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 3.66023 * s),
          blurRadius: 8.96757 * s,
          color: Colors.black.withOpacity(0.07),
        ),
      ],
    );
  }

  // =========================
  // Верхняя карточка (Frame 2131330162)
  // =========================
  Widget _buildProfileCard(BuildContext context) {
    final s = _s(context);

    return Container(
      width: 343 * s,
      height: 172 * s,
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatarFrame(context),
          SizedBox(width: 16 * s),
          _buildInfoBlock(context),
        ],
      ),
    );
  }

  // Avatar frame: frog clipped by green block (97x130), badge outside
  Widget _buildAvatarFrame(BuildContext context) {
    final s = _s(context);

    final outerR = 13.0 * s;
    final blockR = 13.0 * s;

    final blockLeft = 4.0 * s;
    final blockTop = 5.0 * s;
    final blockW = 97.0 * s;
    final blockH = 130.0 * s;

    final frogLeftInOuter = ((105.0 - 94.0) / 2.0 + 0.47) * s;
    final frogTopInOuter = 32.0 * s;

    final frogLeftInBlock = frogLeftInOuter - blockLeft;
    final frogTopInBlock = frogTopInOuter - blockTop;

    return SizedBox(
      width: 105 * s,
      height: 140 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerR),
                border: Border.all(
                  color: const Color(0xFFF5F5F5),
                  width: 2 * s,
                ),
              ),
            ),
          ),
          Positioned(
            left: blockLeft,
            top: blockTop,
            width: blockW,
            height: blockH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(blockR),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: Container(color: const Color(0xFFECFFDE)),
                  ),
                  Positioned(
                    left: frogLeftInBlock,
                    top: frogTopInBlock,
                    width: 94 * s,
                    height: 123 * s,
                    child: Image.asset(
                      _frogAvatarAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 86 * s,
            top: -9 * s,
            width: 28 * s,
            height: 28 * s,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF81C784),
                borderRadius: BorderRadius.circular(122 * s),
              ),
              alignment: Alignment.center,
              child: Text(
                '$userLevel',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  height: 14 / 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(BuildContext context) {
    final s = _s(context);

    return SizedBox(
      width: 188 * s,
      height: 136 * s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 188 * s,
            height: 21 * s,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (firstName.isEmpty ? '...' : firstName),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w700,
                    height: 21 / 18,
                    color: const Color(0xFF191919),
                  ),
                ),
                SizedBox(width: 4 * s),
                Expanded(
                  child: Text(
                    lastName,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w400,
                      height: 17 / 14,
                      color: const Color(0xFF777777),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * s),
          Column(
            children: [
              _infoRow(s, label: 'Баланс:', value: null, isBalance: true),
              SizedBox(height: 4 * s),
              _infoRow(s, label: 'Возраст:', value: _ageText()),
              SizedBox(height: 4 * s),
              _infoRow(s, label: 'Друг:', value: petName),
              SizedBox(height: 4 * s),
              _infoRow(s, label: 'Уровень:', value: '$userLevel'),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 188 * s,
            height: 30 * s,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    height: 14 / 12,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      double s, {
        required String label,
        required String? value,
        bool isBalance = false,
      }) {
    if (isBalance) {
      return SizedBox(
        width: 188 * s,
        height: 15 * s,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                height: 14 / 12,
                color: const Color(0xFF777777),
              ),
            ),
            Row(
              children: [
                Text(
                  '$userCoins',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    height: 14 / 12,
                    color: const Color(0xFF81C784),
                  ),
                ),
                SizedBox(width: 4 * s),
                SizedBox(
                  width: 15 * s,
                  height: 15 * s,
                  child: Image.asset(
                    _coinAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 188 * s,
      height: 14 * s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              height: 14 / 12,
              color: const Color(0xFF777777),
            ),
          ),
          Text(
            value ?? '',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              height: 14 / 12,
              color: const Color(0xFF191919),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Нижние две карточки
  // =========================
  Widget _buildActionsRow(BuildContext context) {
    final s = _s(context);

    return SizedBox(
      width: 343 * s,
      height: 220 * s,
      child: Row(
        children: [
          _buildPhotoDiaryCard(context),
          SizedBox(width: 9 * s),
          _buildMakePhotoCard(context),
        ],
      ),
    );
  }

  // Фото-дневник (book1.png в круге — чуть ниже и по центру)
  Widget _buildPhotoDiaryCard(BuildContext context) {
    final s = _s(context);
    final radius = 26.0 * s;

    // Размеры группы под иконку из CSS
    final groupW = 78.0 * s;
    final groupH = 68.0 * s;

    // Чуть ниже, чем было (центр круга + небольшой +2px)
    final bookTop = ((130.0 - 68.0) / 2.0) * s + 2.0 * s;
    final bookLeft = ((130.0 - 78.0) / 2.0) * s;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/photo_diary'),
      child: Container(
        width: 167 * s,
        height: 220 * s,
        decoration: _cardDecoration(s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.fromLTRB(13 * s, 15 * s, 13 * s, 15 * s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130 * s,
                  height: 146 * s,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        width: 130 * s,
                        height: 130 * s,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF5F5F5),
                              width: 1.32 * s,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: bookLeft,
                        top: bookTop,
                        width: groupW,
                        height: groupH,
                        child: Image.asset(
                          _bookDiaryAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 21 * s,
                  child: Center(
                    child: Text(
                      'Фото-Дневник',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w600,
                        height: 21 / 18,
                        color: const Color(0xFF191919),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Сделать фото (frog2.png, клип по краям карточки, текст поверх, опущен до уровня фото-дневника)
  Widget _buildMakePhotoCard(BuildContext context) {
    final s = _s(context);
    final radius = 26.0 * s;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/photo'),
      child: Container(
        width: 167 * s,
        height: 220 * s,
        decoration: _cardDecoration(s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 8 * s,
                top: -167 * s,
                width: 291 * s,
                height: 345 * s,
                child: Image.asset(
                  _frogMakePhotoAsset,
                  fit: BoxFit.contain,
                ),
              ),

              // Было bottom: 26*s. Опускаем до уровня "Фото-Дневник".
              Positioned(
                left: 13 * s,
                right: 13 * s,
                bottom: 18.5 * s,
                height: 21 * s,
                child: Center(
                  child: Text(
                    'Сделать фото',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w600,
                      height: 21 / 18,
                      color: const Color(0xFF191919),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
