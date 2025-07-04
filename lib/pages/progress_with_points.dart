import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressWithPoints extends StatelessWidget {
  final double progress; // от 0.0 до 1.0
  final int points;

  const ProgressWithPoints({
    super.key,
    required this.progress,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Огонь с цифрой 3
          // Огонь с цифрой 3
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                // Поднимаем гифку вверх, уменьшая отступ снизу
                padding: const EdgeInsets.only(bottom: 30), // ← Поднимает вверх!
                child: SizedBox(
                  width: 50, // ← Было 40 — теперь гифка больше
                  height: 50,
                  child: Image.asset(
                    'assets/image/Fire.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Text(
                '3',
                style: TextStyle(
                  fontSize: 20, // Можно чуть увеличить текст тоже
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

          // Прогресс-бар с текстом
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
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.green),
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
