import 'package:flutter/material.dart';
import '../game_scripts.dart';

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

  static const double fireWidth = 78;
  static const double fireHeight = 78;
  static const double fireTopOffset = 18;

  const StreakCard({
    super.key,
    this.width = 178,
    this.height = 236,
    this.totalDots = 7,
    this.litThreshold = 0,
    this.title = 'Серия заходов',
    this.litAsset = 'assets/newimage/fire_yellow.png',
    this.dimAsset = 'assets/newimage/fire_grey.png',
    this.activeDotColor = const Color(0xFF81C784),
    this.inactiveDotColor = const Color(0xFFF2F2F2),
    this.cardBorderColor = const Color(0xFF81C784),
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int streak = 1;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final fetchedStreak = await GamificationService().getLoginStreak();
    if (mounted) {
      setState(() => streak = fetchedStreak);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLit = streak > widget.litThreshold;
    final String fireImage = isLit ? widget.litAsset : widget.dimAsset;
    final int activeDots = streak.clamp(0, widget.totalDots);

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        border: isLit
            ? Border.all(width: 4, color: widget.cardBorderColor)
            : null,
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
                        color: isLit
                            ? const Color(0xFFFF8E4D)
                            : const Color(0xFFE4E4E4),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.totalDots, (i) {
                  final bool on = i < activeDots;
                  return Container(
                    margin: EdgeInsets.only(
                        right: i == widget.totalDots - 1 ? 0 : 4),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: on
                          ? widget.activeDotColor
                          : widget.inactiveDotColor,
                      borderRadius: BorderRadius.circular(64),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
