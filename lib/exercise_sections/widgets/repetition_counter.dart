// 📁 widgets/repetition_counter.dart
import 'package:flutter/material.dart';

class RepetitionCounter extends StatelessWidget {
  final int count;
  const RepetitionCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          '$count / 10',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}