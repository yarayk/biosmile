import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game_scripts.dart';

enum StreakCardView { expanded, compact }

// --- Локальное чтение дней недели ---
Future<List<int>> getLoginDaysForThisWeek() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now();
  final weekYear = "${today.year}-${weekNumber(today)}";
  final key = "login_days_$weekYear";
  List<String> days = prefs.getStringList(key) ?? [];
  return days.map((x) => int.tryParse(x) ?? 0).where((x) => x > 0).toList();
}

int weekNumber(DateTime date) {
  final first = DateTime(date.year, 1, 1);
  return ((date.difference(first).inDays + first.weekday - 1) / 7).floor() + 1;
}
// -------------------------------------------------

class StreakCard extends StatefulWidget {
  final double width;
  final double height;

  final int totalDots;
  final int litThreshold;
  final String title;

  final String litAsset;
  final String dimAsset;

  final Color activeDotColor;
  final Color inactiveDotColor;
  final Color cardBorderColor;
  final EdgeInsetsGeometry padding;

  final StreakCardView view;

  static const double fireWidth = 78;
  static const double fireHeight = 78;
  static const double fireTopOffset = 18;

  const StreakCard({
    super.key,
    this.width = 178,
    this.height = 237,
    this.totalDots = 7,
    this.litThreshold = 0,
    this.title = 'Серия заходов',
    this.litAsset = 'assets/newimage/fire_yellow.png',
    this.dimAsset = 'assets/newimage/fire_grey.png',
    this.activeDotColor = const Color(0xFF81C784),
    this.inactiveDotColor = const Color(0xFFF2F2F2),
    this.cardBorderColor = const Color(0xFF81C784),
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
    this.view = StreakCardView.expanded,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int? streak;
  bool loading = true;

  late Future<List<int>> _daysFuture;

  @override
  void initState() {
    super.initState();
    _daysFuture = getLoginDaysForThisWeek();
    _reloadStreak();
  }

  Future<void> _reloadStreak() async {
    setState(() {
      loading = true;
      streak = null;
    });

    final fetchedStreak = await GamificationService().getLoginStreak();
    if (!mounted) return;

    setState(() {
      streak = fetchedStreak;
      loading = false;
    });

    Future.delayed(const Duration(milliseconds: 400), () async {
      final freshStreak = await GamificationService().getLoginStreak();
      if (mounted && streak != freshStreak) {
        setState(() => streak = freshStreak);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (streak == null || loading) {
      return Center(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final bool isLit = streak! > widget.litThreshold;
    final String fireImage = isLit ? widget.litAsset : widget.dimAsset;

    if (widget.view == StreakCardView.compact) {
      return _CompactStreakCardCssStrict(
        width: widget.width,
        height: widget.height,
        currentStreak: streak!,
        daysFuture: _daysFuture,
        activeDotColor: widget.activeDotColor,
        inactiveDotColor: widget.inactiveDotColor,
        fireCurrentAsset: fireImage,     // 1-й круг: горит/не горит как в expanded
        fireAlwaysLitAsset: widget.litAsset, // 3-й круг: всегда горящий
        recordFixed: 3,                  // фикс как просил
      );
    }

    // --------- EXPANDED (твоё текущее состояние) ---------
    final bool showBorder = streak! > 1;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        border: showBorder ? Border.all(width: 4, color: widget.cardBorderColor) : null,
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            blurRadius: 9,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF5F5F5),
                        width: 1.32,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    child: Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isLit ? const Color(0xFFFF8E4D) : const Color(0xFFE4E4E4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    child: Container(
                      width: 130,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          streak.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 64,
                            height: 1.0,
                            color: Color(0xFF191919),
                            shadows: [
                              Shadow(
                                blurRadius: 1.5,
                                color: Color(0xFFB16742),
                                offset: Offset(0, 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: StreakCard.fireTopOffset,
                    child: Image.asset(
                      fireImage,
                      width: StreakCard.fireWidth,
                      height: StreakCard.fireHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 21 / 18,
                  color: Color(0xFF191919),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<int>>(
                future: _daysFuture,
                builder: (context, snapshot) {
                  final days = snapshot.data ?? [];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.totalDots, (i) {
                      final dayNum = i + 1; // Пн=1 ... Вс=7
                      final on = days.contains(dayNum);
                      return Container(
                        margin: EdgeInsets.only(right: i == widget.totalDots - 1 ? 0 : 4),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: on ? widget.activeDotColor : widget.inactiveDotColor,
                          borderRadius: BorderRadius.circular(64),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact state: строго по CSS, который ты прислал.
class _CompactStreakCardCssStrict extends StatelessWidget {
  final double width;
  final double height;

  final int currentStreak;
  final int recordFixed;

  final String fireCurrentAsset;     // 1-й круг: горит/не горит
  final String fireAlwaysLitAsset;   // 3-й круг: всегда горит

  final Color activeDotColor;
  final Color inactiveDotColor;

  final Future<List<int>> daysFuture;

  const _CompactStreakCardCssStrict({
    required this.width,
    required this.height,
    required this.currentStreak,
    required this.recordFixed,
    required this.fireCurrentAsset,
    required this.fireAlwaysLitAsset,
    required this.activeDotColor,
    required this.inactiveDotColor,
    required this.daysFuture,
  });

  @override
  Widget build(BuildContext context) {
    // CSS база: width 74, height 237
    final s = width / 74.0;

    // Frame 2131330155
    final outerPadding = 4.0 * s;   // padding: 4px
    final gap = 8.0 * s;            // gap: 8px
    final radiusOuter = 26.0 * s;   // border-radius: 26px

    // Child circles
    final circleSize = 66.0 * s;
    final circleBorder = 0.67 * s;
    final circleRadius = 100.0 * s;
    final shadow = BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.10),
      blurRadius: 12.0 * s,
      offset: Offset(0, 2.0 * s),
    );

    // gap + space-between (как flex space-between + gap)
    final innerHeight = height - outerPadding * 2;
    final extra = innerHeight - (circleSize * 3) - (gap * 2);
    final between = gap + (extra > 0 ? extra / 2 : 0);

    Widget circleCard({required Widget child}) {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF5F5F5), width: circleBorder),
          boxShadow: [shadow],
          borderRadius: BorderRadius.circular(circleRadius),
        ),
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusOuter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // align-items: flex-start
        children: [
          Center(
            child: circleCard(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 11.5 * s,
                    top: 12.75 * s,
                    child: Image.asset(
                      fireCurrentAsset,
                      width: 43.0 * s,
                      height: 48.5 * s,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: between),
          Center(
            child: FutureBuilder<List<int>>(
              future: daysFuture,
              builder: (context, snapshot) {
                final days = snapshot.data ?? <int>[];
                return circleCard(
                  child: _CssMiddleCircleStrict(
                    s: s,
                    number: currentStreak,
                    daysOn: days,
                    activeDotColor: activeDotColor,
                    inactiveDotColor: inactiveDotColor,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: between),
          Center(
            child: circleCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 26.0 * s,
                    height: 24.0 * s,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: SizedBox(
                            width: 14.0 * s,
                            height: 24.0 * s,
                            child: Text(
                              recordFixed.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 24.0 * s,
                                height: 1.0,
                                color: const Color(0xFF191919),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12.0 * s,
                          top: 4.5 * s,
                          child: Image.asset(
                            fireAlwaysLitAsset,
                            width: 16.0 * s,
                            height: 18.0 * s,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0 * s),
                  SizedBox(
                    width: 38.0 * s,
                    height: 14.0 * s,
                    child: const Text(
                      'МАКС.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 14 / 12,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CssMiddleCircleStrict extends StatelessWidget {
  final double s;
  final int number;
  final List<int> daysOn; // 1..7 (Пн..Вс)
  final Color activeDotColor;
  final Color inactiveDotColor;

  const _CssMiddleCircleStrict({
    required this.s,
    required this.number,
    required this.daysOn,
    required this.activeDotColor,
    required this.inactiveDotColor,
  });

  @override
  Widget build(BuildContext context) {
    // Точки строго по CSS (left/top) внутри 66x66
    const dotPosBase = <Offset>[
      Offset(29, 56), // 34624192
      Offset(38, 54), // 34624193
      Offset(46, 50), // 34624196
      Offset(52, 43), // 34624197
      Offset(6, 43),  // 34624198
      Offset(20, 54), // 34624194
      Offset(12, 50), // 34624195
    ];

    // Привязка дней к точкам (чтобы логика работала предсказуемо):
    // day 1..7 раскладываем по дуге слева->вправо (как обычно).
    // В CSS перечисление другое, поэтому даём явное соответствие.
    const dayToDotIndex = <int>[
      4, // day1 -> (6,43)
      6, // day2 -> (12,50)
      5, // day3 -> (20,54)
      0, // day4 -> (29,56)
      1, // day5 -> (38,54)
      2, // day6 -> (46,50)
      3, // day7 -> (52,43)
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: SizedBox(
            width: 28.0 * s,
            height: 40.0 * s,
            child: Text(
              number.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 40.0 * s,
                height: 1.0,
                color: const Color(0xFF191919),
              ),
            ),
          ),
        ),
        for (int day = 1; day <= 7; day++)
          Positioned(
            left: dotPosBase[dayToDotIndex[day - 1]].dx * s,
            top: dotPosBase[dayToDotIndex[day - 1]].dy * s,
            child: Container(
              width: 8.0 * s,
              height: 8.0 * s,
              decoration: BoxDecoration(
                color: daysOn.contains(day) ? activeDotColor : inactiveDotColor,
                borderRadius: BorderRadius.circular(64.0541 * s),
              ),
            ),
          ),
      ],
    );
  }
}
