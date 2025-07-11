// 📁 widgets/start_button.dart
import 'package:flutter/material.dart';

class StartExerciseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const StartExerciseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      ),
      child: const Text(
        'Начать упражнение',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}