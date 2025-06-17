import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face10 extends StatelessWidget {
  const Face10({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Звук "М"',
      navigationRoute: '/face_10_exercises',
    );
  }
}
