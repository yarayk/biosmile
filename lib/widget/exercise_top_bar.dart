import 'package:flutter/material.dart';
import '../game_scripts.dart'; // GamificationService

class ExerciseTopBar extends StatefulWidget {
  final int coins;
  final int currentXp;
  final int nextXp;

  final String fireLitAsset;
  final String fireDimAsset;

  final String coinAsset;

  const ExerciseTopBar({
    super.key,
    required this.coins,
    required this.currentXp,
    required this.nextXp,
    this.fireLitAsset = 'assets/newimage/fire_yellow.png',
    this.fireDimAsset = 'assets/newimage/fire_grey.png',
    this.coinAsset = 'assets/newimage/coin_20.png',
  });

  @override
  State<ExerciseTopBar> createState() => _ExerciseTopBarState();
}

class _ExerciseTopBarState extends State<ExerciseTopBar> {
  int? streak;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _reloadStreak();
  }

  Future<void> _reloadStreak() async {
    setState(() {
      loading = true;
      streak = null;
    });

    final fetched = await GamificationService().getLoginStreak();
    if (!mounted) return;

    setState(() {
      streak = fetched;
      loading = false;
    });

    Future.delayed(const Duration(milliseconds: 400), () async {
      final fresh = await GamificationService().getLoginStreak();
      if (!mounted) return;
      if (streak != fresh) setState(() => streak = fresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double baseW = 375.0;
        final double w = constraints.maxWidth;
        final double scale = (w / baseW).clamp(0.85, 1.25);

        // ====== размеры/позиции из Figma (375x105) ======
        const double topbarH = 105.0;

        // money absolute group
        const double moneyW = 48.0;
        const double moneyH = 73.76;
        const double moneyLeft = 16.0;
        const double moneyTop = 16.0;

        // Counter (absolute): left=88, top=27, w=199, h=51
        const double counterLeft = 88.0;
        const double counterTop = 27.0;
        const double counterW = 199.0;
        const double counterH = 51.0;

        // Count chip: left=149, top=90, w=78, h=27
        const double countW = 78.0;
        const double countH = 27.0;
        const double countLeft = 149.0;
        const double countTop = 90.0;

        // Fire image: left=298, top=8.25, w=74, h=88.5
        const double fireW = 74.0;
        const double fireH = 88.5;
        const double fireLeft = 298.0;
        const double fireTop = 8.25;

        // Streak number: left=326.5, top=41
        const double streakLeft = 326.5;
        const double streakTop = 41.0;

        // ===============================================

        final int total = widget.nextXp <= 0 ? 1 : widget.nextXp;
        final int current = widget.currentXp.clamp(0, total);
        final double ratio = (current / total).clamp(0.0, 1.0);

        final int streakValue = (streak ?? 0);
        final bool isLit = streakValue > 2;
        final String fireAsset = isLit ? widget.fireLitAsset : widget.fireDimAsset;

        return SizedBox(
          width: double.infinity,
          height: topbarH * scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4 * scale),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // MONEY
                Positioned(
                  left: moneyLeft * scale,
                  top: moneyTop * scale,
                  width: moneyW * scale,
                  height: moneyH * scale,
                  child: _moneyBlock(scale, widget.coins),
                ),

                // CENTER counter (absolute)
                Positioned(
                  left: counterLeft * scale,
                  top: counterTop * scale,
                  width: counterW * scale,
                  height: counterH * scale,
                  child: _centerCounter(scale, ratio),
                ),

                // FIRE (без тени)
                Positioned(
                  left: fireLeft * scale,
                  top: fireTop * scale,
                  width: fireW * scale,
                  height: fireH * scale,
                  child: Image.asset(
                    fireAsset,
                    fit: BoxFit.contain,
                  ),
                ),

                // STREAK number (absolute)
                Positioned(
                  left: streakLeft * scale,
                  top: streakTop * scale,
                  child: SizedBox(
                    width: 16 * scale,
                    height: 24 * scale,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        loading ? '' : streakValue.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 24 * scale,
                          height: 1.0,
                          color: const Color(0xFF191919),
                        ),
                      ),
                    ),
                  ),
                ),

                // COUNT chip (absolute, центр)
                Positioned(
                  left: countLeft * scale,
                  top: countTop * scale,
                  width: countW * scale,
                  height: countH * scale,
                  child: _countChip(scale, '$current/$total'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _moneyBlock(double scale, int coins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // БЫЛО: серый фон + маленькая монета
        // СТАЛО: монета занимает весь размер 48 x 47.76 без серого круга
        SizedBox(
          width: 48 * scale,
          height: 47.76 * scale,
          child: Image.asset(
            widget.coinAsset,
            width: 48 * scale,
            height: 47.76 * scale,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 5 * scale),

        // чип с количеством (по CSS с тенью)
        Container(
          width: 48 * scale,
          height: 21 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35 * scale),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            coins.toString(),
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
              height: 17 / 14,
              color: const Color(0xFF81C784),
            ),
          ),
        ),
      ],
    );
  }

  Widget _centerCounter(double scale, double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Осталось до\nследующего уровня',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 12 * scale,
            height: 14 / 12,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8 * scale),
        _progressBar(scale: scale, ratio: ratio),
      ],
    );
  }

  Widget _progressBar({required double scale, required double ratio}) {
    final double w = 199 * scale;
    final double h = 15 * scale;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF81C784), width: 1),
        borderRadius: BorderRadius.circular(131 * scale),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(39 * scale),
          child: Container(
            width: w * ratio,
            height: h,
            color: const Color(0xFF81C784),
          ),
        ),
      ),
    );
  }

  Widget _countChip(double scale, String text) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w600,
          fontSize: 10 * scale,
          height: 12 / 10,
          color: const Color(0xFF81C784),
        ),
      ),
    );
  }
}
