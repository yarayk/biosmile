import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face6 extends StatelessWidget {
  const Face6({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Прищуривайся, подтягивая нижнее веко',
      navigationRoute: '/face_6_exercises',
    );
  }
}
