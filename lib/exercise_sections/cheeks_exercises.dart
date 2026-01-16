import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/widget/tabbar.dart';

class _ExerciseNode {
  final int number;
  final String route;
  final double x;
  final double y;

  const _ExerciseNode({
    required this.number,
    required this.route,
    required this.x,
    required this.y,
  });
}

class _ExerciseMeta {
  final int number;
  final String title; // без "1."
  final String route;

  const _ExerciseMeta({
    required this.number,
    required this.title,
    required this.route,
  });
}

class CheeksExercisesPage extends StatefulWidget {
  const CheeksExercisesPage({super.key});

  @override
  State<CheeksExercisesPage> createState() => _CheeksExercisesPageState();
}

class _CheeksExercisesPageState extends State<CheeksExercisesPage> {
  // ===== Figma frame =====
  static const double _designW = 375.0;
  static const double _designH = 812.0;

  // ===== Island-like tuning =====
  static const double _yOffset = 0.0;
  static const double _bottomCrop = 0.0;

  // ===== Background road (CSS) =====
  static const double _bgW = 597.0;
  static const double _bgH = 2048.0;
  static const double _bgLeft = -111.0;
  static const double _bgTop = -65.0;

  // ===== Buttons on map =====
  static const double _btnW = 87.0;
  static const double _btnH = 91.0;

  static const double _numDx = 10.0;
  static const double _numDy = 19.0;
  static const double _numW = 67.0;
  static const double _numH = 48.0;

  // ===== Selection highlight =====
  static const double _selW = 118.0;
  static const double _selH = 118.0;

  // ===== Header =====
  static const double _headerH = 88.0;
  static const double _titleTop = 53.0;
  static const double _titleFont = 18.0;
  static const double _titleLineH = 21.0;

  static const double _backLeft = 16.0;
  static const double _backTop = 47.0;
  static const double _backBox = 34.0;
  static const double _backRadius = 10.3636;
  static const double _arrowSize = 18.0;

  // ===== Bottom panel =====
  static const double _panelW = 343.0;
  static const double _panelGap = 20.0;

  static const double _cardRadius = 26.0;
  static const double _cardPadding = 16.0;
  static const double _cardGap = 16.0;

  static const double _pillW = 65.0;
  static const double _pillH = 23.0;
  static const double _pillRadius = 35.0;

  static const double _startBtnH = 51.0;
  static const double _startBtnRadius = 64.0;

  // ===== Assets =====
  static const String roadBgAsset = 'assets/exercise/fon2_2.png';

  static const String buttonAsset = 'assets/exercise/exercise_btn.png';
  static const String arrowAsset = 'assets/exercise/arrow_black.png';

  static const String timeAsset = 'assets/exercise/time.png';
  static const String starAsset = 'assets/exercise/star.png';
  static const String coinAsset = 'assets/newimage/coin_20.png';

  static const String selectedBgAsset = 'assets/exercise/fon_buttom.png';

  // ===== "Last task" keys =====
  static const String _kLastSectionTitle = 'last_section_title';
  static const String _kLastSectionRoute = 'last_section_route';

  static const String _kLastExerciseNumber = 'last_exercise_number';
  static const String _kLastExerciseTitle = 'last_exercise_title';
  static const String _kLastExerciseRoute = 'last_exercise_route';

  // ===== Current section identity =====
  static const String _sectionTitle = 'Упражнения для щек';
  static const String _sectionRoute = '/cheeks_exercises';

  // ===== Exercises meta =====
  static const List<_ExerciseMeta> exercises = [
    _ExerciseMeta(number: 1, title: 'Надуть обе щеки', route: '/cheeks_1'),
    _ExerciseMeta(number: 2, title: 'Втянуть щеки', route: '/cheeks_2'),
    _ExerciseMeta(number: 3, title: 'Надуть правую щеку, затем левую', route: '/cheeks_3'),
    _ExerciseMeta(number: 4, title: 'Чередовать 1 и 2', route: '/cheeks_4'),
    _ExerciseMeta(number: 5, title: 'Имитировать полоскание', route: '/cheeks_5'),
  ];

  // ===== Nodes positions (CSS) =====
  static const List<_ExerciseNode> nodes = [
    _ExerciseNode(number: 1, route: '/cheeks_1', x: 55,  y: 148),
    _ExerciseNode(number: 2, route: '/cheeks_2', x: 233, y: 148),
    _ExerciseNode(number: 3, route: '/cheeks_3', x: 144, y: 319),
    _ExerciseNode(number: 4, route: '/cheeks_4', x: 55,  y: 490),
    _ExerciseNode(number: 5, route: '/cheeks_5', x: 233, y: 490),
  ];

  // ==== Tabbar ====
  int selectedTabIndex = 1;

  final List<String> routes = const [
    '/home',
    '/exercise_sections',
    '/photo_diary',
    '/profile_first',
  ];

  final List<int> iconStates01 = [0, 1, 0, 0];

  void _onTabSelected(int index) {
    setState(() => selectedTabIndex = index);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    final targetRoute = routes[index];

    if (currentRoute != targetRoute) {
      Navigator.of(context).pushNamed(targetRoute);
    }
  }

  // ===== Selected exercise =====
  _ExerciseMeta? selectedExercise;
  int? selectedNumber;

  void _onExerciseCircleTap(int number) {
    if (selectedNumber == number) {
      setState(() {
        selectedNumber = null;
        selectedExercise = null;
      });
      return;
    }

    final ex = exercises.firstWhere((e) => e.number == number);
    setState(() {
      selectedNumber = number;
      selectedExercise = ex;
    });
  }

  Future<void> _saveLastSection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSectionTitle, _sectionTitle);
    await prefs.setString(_kLastSectionRoute, _sectionRoute);
  }

  Future<void> _saveLastExercise(_ExerciseMeta ex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastExerciseNumber, ex.number);
    await prefs.setString(_kLastExerciseTitle, ex.title);
    await prefs.setString(_kLastExerciseRoute, ex.route);
  }

  Future<void> _onStartPressed() async {
    final ex = selectedExercise;
    if (ex == null) return;

    await _saveLastSection();
    await _saveLastExercise(ex);

    if (!mounted) return;

    setState(() {
      selectedNumber = null;
      selectedExercise = null;
    });

    Navigator.pushNamed(context, ex.route);
  }

  double _scaleFor(double screenW) => (screenW / _designW).clamp(0.85, 1.35);

  _ExerciseNode? _nodeByNumber(int number) {
    for (final n in nodes) {
      if (n.number == number) return n;
    }
    return null;
  }

  // ===== Header fixed =====
  Widget _buildFixedHeader(BuildContext context, double screenW) {
    final scale = _scaleFor(screenW);
    final safeTop = MediaQuery.paddingOf(context).top;

    final headerContentH = _headerH * scale;
    final headerTotalH = safeTop + headerContentH;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: headerTotalH,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0xFFFB9C61).withAlpha((0.35 * 255).round()),
            child: Stack(
              children: [
                Positioned(
                  left: _backLeft * scale,
                  top: safeTop + (_backTop * scale),
                  width: _backBox * scale,
                  height: _backBox * scale,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
                        borderRadius: BorderRadius.circular(_backRadius * scale),
                      ),
                      child: Image.asset(
                        arrowAsset,
                        width: _arrowSize * scale,
                        height: _arrowSize * scale,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: safeTop + (_titleTop * scale),
                  height: _titleLineH * scale,
                  child: Center(
                    child: Text(
                      'Упражнения для щек',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        fontSize: _titleFont * scale,
                        height: _titleLineH / _titleFont,
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

  // ===== Map scene =====
  Widget _buildScrollableScene(double screenW) {
    final scale = _scaleFor(screenW);
    final canvasH = (_designH - _bottomCrop).clamp(0.0, double.infinity) * scale;

    final selectedNode =
    (selectedNumber == null) ? null : _nodeByNumber(selectedNumber!);

    return SizedBox(
      width: screenW,
      height: canvasH,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: _bgLeft * scale,
              top: (_bgTop + _yOffset) * scale,
              width: _bgW * scale,
              height: _bgH * scale,
              child: Image.asset(
                roadBgAsset,
                fit: BoxFit.fill,
                alignment: Alignment.topLeft,
                filterQuality: FilterQuality.high,
              ),
            ),

            if (selectedNode != null)
              Positioned(
                left: (selectedNode.x + (_btnW / 2) - (_selW / 2)) * scale,
                top: ((selectedNode.y + (_btnH / 2) - (_selH / 2)) + _yOffset) * scale,
                width: _selW * scale,
                height: _selH * scale,
                child: IgnorePointer(
                  child: Image.asset(
                    selectedBgAsset,
                    width: _selW * scale,
                    height: _selH * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

            for (final n in nodes)
              Positioned(
                left: n.x * scale,
                top: (n.y + _yOffset) * scale,
                width: _btnW * scale,
                height: _btnH * scale,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _onExerciseCircleTap(n.number),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          buttonAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        left: _numDx * scale,
                        top: _numDy * scale,
                        width: _numW * scale,
                        height: _numH * scale,
                        child: Center(
                          child: Text(
                            n.number.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              fontSize: 40 * scale,
                              height: 48 / 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== Bottom panel =====
  Widget _buildInfoPill({
    required double scale,
    required Widget icon,
    required String text,
  }) {
    return SizedBox(
      width: _pillW * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32 * scale,
            height: 32 * scale,
            child: Center(child: icon),
          ),
          SizedBox(height: 5 * scale),
          Container(
            height: _pillH * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_pillRadius * scale),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                  height: 17 / 14,
                  color: const Color(0xFF81C784),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, double screenW) {
    final ex = selectedExercise;
    if (ex == null) return const SizedBox.shrink();

    final scale = _scaleFor(screenW);

    return Center(
      child: SizedBox(
        width: _panelW * scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _panelW * scale,
              padding: EdgeInsets.all(_cardPadding * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius * scale),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Упражнение № ${ex.number}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          fontSize: 16 * scale,
                          height: 19 / 16,
                          color: const Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.title,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * scale,
                          height: 21 / 18,
                          color: const Color(0xFF191919),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _cardGap * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoPill(
                        scale: scale,
                        icon: Image.asset(
                          timeAsset,
                          width: 32 * scale,
                          height: 32 * scale,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        text: '3 мин.',
                      ),
                      SizedBox(width: 37 * scale),
                      _buildInfoPill(
                        scale: scale,
                        icon: Image.asset(
                          starAsset,
                          width: 32 * scale,
                          height: 32 * scale,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        text: '+25 ед.',
                      ),
                      SizedBox(width: 37 * scale),
                      _buildInfoPill(
                        scale: scale,
                        icon: Image.asset(
                          coinAsset,
                          width: 33 * scale,
                          height: 32 * scale,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        text: '+20',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: _panelGap * scale),
            SizedBox(
              width: _panelW * scale,
              height: _startBtnH * scale,
              child: ElevatedButton(
                onPressed: _onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81C784),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_startBtnRadius * scale),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 16 * scale,
                  ),
                ),
                child: Text(
                  'Начать',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * scale,
                    height: 19 / 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFB9C61),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildScrollableScene(screenW),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                _buildFixedHeader(context, screenW),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: selectedExercise == null
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBottomPanel(context, screenW),
                ),
              ),
              MainTabBar(
                iconStates01: iconStates01,
                selectedIndex: selectedTabIndex,
                onTabSelected: _onTabSelected,
              ),
            ],
          );
        },
      ),
    );
  }
}
