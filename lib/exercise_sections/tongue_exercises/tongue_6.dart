import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Tongue6 extends StatelessWidget {
  const Tongue6({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для языка',
      exerciseTitle: 'Языком погладить твердое небо',
      navigationRoute: '/tongue_6_exercises',
    );
  }
}
