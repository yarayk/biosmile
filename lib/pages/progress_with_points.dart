import 'package:flutter/material.dart';

class ProgressWithPoints extends StatelessWidget {
  final double progress; // от 0.0 до 1.0
  final int points;
  final int streak; // поле для отображения серии заходов

  ProgressWithPoints({
    super.key,
    required this.progress,
    required this.points,
    this.streak = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // цифра login_streak
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(
                    'assets/image/Fire.gif',
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
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}/100',
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

          // Очки
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 20),
              const SizedBox(width: 4),
              Text(
                points.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.pink,
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
