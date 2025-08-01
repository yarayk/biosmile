import 'package:flutter/material.dart';

class AchievementPopup extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final int coins;

  const AchievementPopup({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.coins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '+$coins 🪙',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Image.asset(imagePath, height: 80),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
