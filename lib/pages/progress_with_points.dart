import 'package:flutter/material.dart';
import '../game_scripts.dart'; // подключи свой сервис

class ProgressWithPoints extends StatefulWidget {
  final double progress; // от 0.0 до 1.0
  final int points;

  const ProgressWithPoints({
    super.key,
    required this.progress,
    required this.points,
  });

  @override
  State<ProgressWithPoints> createState() => _ProgressWithPointsState();
}

class _ProgressWithPointsState extends State<ProgressWithPoints> {
  int streak = 1;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    int fetchedStreak = await GamificationService().getLoginStreak();
    setState(() {
      streak = fetchedStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    String fireImage = streak > 2
        ? 'assets/image/fire_yellow.png'
        : 'assets/image/fire_grey.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Огненная иконка + цифра серии
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: 33,
                  height: 33,
                  child: Image.asset(
                    fireImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                streak.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Прогресс-бар
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                Text(
                  '${(widget.progress * 100).toInt()}/100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Очки с иконкой рыбы
          Row(
            children: [
              Image.asset(
                'assets/image/fish.png',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 4),
              Text(
                widget.points.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
