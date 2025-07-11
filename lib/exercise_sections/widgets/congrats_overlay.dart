// 📁 widgets/congrats_overlay.dart
import 'package:flutter/material.dart';

class CongratsOverlay extends StatelessWidget {
  const CongratsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(
            image: AssetImage('assets/image/happy.png'),
            width: 200,
            height: 200,
          ),
          SizedBox(height: 20),
          Text(
            'Поздравляем!\nУпражнение выполнено.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}