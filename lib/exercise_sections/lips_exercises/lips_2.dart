import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Lips2 extends StatelessWidget {
  const Lips2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для губ',
      exerciseTitle: 'Движения “трубочкой”',
      navigationRoute: '/lips_2_exercises',
    );
  }
}
