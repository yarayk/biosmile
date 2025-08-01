import 'package:flutter/material.dart';
import 'achievement_popup.dart';

void showAchievementPopup({
  required BuildContext context,
  required String title,
  required String imagePath,
  required String description,
  required int coins,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AchievementPopup(
      title: title,
      imagePath: imagePath,
      description: description,
      coins: coins,
    ),
  );
}
