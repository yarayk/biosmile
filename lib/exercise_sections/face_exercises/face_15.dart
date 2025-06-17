import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face15 extends StatelessWidget {
  const Face15({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Произноси “Т”, “П”, “Р”, “У”',
      navigationRoute: '/face_15_exercises',
    );
  }
}
