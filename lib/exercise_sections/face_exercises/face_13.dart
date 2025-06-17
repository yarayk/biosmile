import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face13 extends StatelessWidget {
  const Face13({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Звук "У", "А"',
      navigationRoute: '/face_13_exercises',
    );
  }
}
