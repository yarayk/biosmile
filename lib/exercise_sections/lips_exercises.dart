import 'dart:ui';
import 'package:flutter/material.dart';
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

class LipsExercisesPage extends StatefulWidget {
  const LipsExercisesPage({super.key});

  @override
  State<LipsExercisesPage> createState() => _LipsExercisesPageState();
}

class _LipsExercisesPageState extends State<LipsExercisesPage> {
  // ===== Figma frame =====
  static const double _designW = 375.0;
  static const double _designH = 1082.0;

  // ===== Island-like tuning =====
  static const double _yOffset = 0.0;
  static const double _bottomCrop = 0.0;

  // ===== Background road (CSS) =====
  static const double _bgW = 691.0;
  static const double _bgH = 1347.0;
  static const double _bgLeft = -138.0;
  static const double _bgTop = -75.0;

  // ===== Buttons on map =====
  static const double _btnW = 87.0;
  static const double _btnH = 91.0;

  static const double _numDx = 10.0;
  static const double _numDy = 19.0;
  static const double _numW = 67.0;
  static const double _numH = 48.0;

  // ===== Selection highlight (NEW) =====
  static const double _selW = 118.0;
  static const double _selH = 118.0;

  // ===== Header (height 108, top 0, title top 73, back top 67) =====
  static const double _headerH = 88.0;
  static const double _titleTop = 53.0;
  static const double _titleFont = 18.0;
  static const double _titleLineH = 21.0;

  static const double _backLeft = 16.0;
  static const double _backTop = 47.0;
  static const double _backBox = 34.0;
  static const double _backRadius = 10.3636;
  static const double _arrowSize = 18.0;

  // ===== Bottom panel (card + button) =====
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
  static const String roadBgAsset = 'assets/exercise/lips_road_bg.png';
  static const String buttonAsset = 'assets/exercise/exercise_btn.png';
  static const String arrowAsset = 'assets/exercise/arrow_black.png';

  static const String timeAsset = 'assets/exercise/time.png';
  static const String starAsset = 'assets/exercise/star.png';
  static const String coinAsset = 'assets/newimage/coin_20.png';

  // NEW highlight asset under selected button
  static const String selectedBgAsset = 'assets/exercise/fon_buttom.png';

  // ===== Exercises meta =====
  static const List<_ExerciseMeta> exercises = [
    _ExerciseMeta(number: 1, title: 'Вытянуть губы вперед - трубочкой', route: '/lips_1'),
    _ExerciseMeta(number: 2, title: 'Движения “трубочкой”', route: '/lips_2'),
    _ExerciseMeta(number: 3, title: 'Трубочка-улыбочка поочередно', route: '/lips_3'),
    _ExerciseMeta(number: 4, title: 'Улыбка', route: '/lips_4'),
    _ExerciseMeta(number: 5, title: 'Длинное задание', route: '/lips_5'),
    _ExerciseMeta(number: 6, title: 'Захватывать зубами верхние и нижние губы', route: '/lips_6'),
    _ExerciseMeta(number: 7, title: 'Оскалиться', route: '/lips_7'),
  ];

  // ===== Nodes positions (CSS) =====
  static const List<_ExerciseNode> nodes = [
    _ExerciseNode(number: 1, route: '/lips_1', x: 144, y: 144),
    _ExerciseNode(number: 2, route: '/lips_2', x: 55,  y: 313),
    _ExerciseNode(number: 3, route: '/lips_3', x: 233, y: 313),
    _ExerciseNode(number: 4, route: '/lips_4', x: 144, y: 482),
    _ExerciseNode(number: 5, route: '/lips_5', x: 55,  y: 651),
    _ExerciseNode(number: 6, route: '/lips_6', x: 233, y: 651),
    _ExerciseNode(number: 7, route: '/lips_7', x: 144, y: 820),
  ];

  // ==== Tabbar (как на островах) ====
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

  // ===== Selected exercise & highlight =====
  _ExerciseMeta? selectedExercise;
  int? selectedNumber; // NEW: какой кружок выделен

  void _onExerciseCircleTap(int number) {
    // повторный тап по выбранной — закрыть всё
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

  void _onStartPressed() {
    final ex = selectedExercise;
    if (ex == null) return;

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
            color: const Color(0xFFF9CA82).withAlpha((0.35 * 255).round()),
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
                      'Упражнение для губ',
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

  // ===== Map scene (фон + выделение + кружки) =====
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
            // background
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

            // NEW: highlight under selected circle (drawn BEFORE buttons)
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

            // circles
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

  // ===== Bottom panel widgets =====
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
      backgroundColor: const Color(0xFFF9CA82),

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
