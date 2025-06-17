import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face14 extends StatelessWidget {
  const Face14({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Рот открыт, звуки “О”, “А”',
      navigationRoute: '/face_14_exercises',
    );
  }
}
