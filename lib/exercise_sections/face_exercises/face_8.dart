import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face8 extends StatelessWidget {
  const Face8({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Сморщь нос',
      navigationRoute: '/face_8_exercises',
    );
  }
}
