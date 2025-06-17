import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Lips3 extends StatelessWidget {
  const Lips3({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для губ',
      exerciseTitle: 'Трубочка-улыбочка поочередно',
      navigationRoute: '/lips_3_exercises',
    );
  }
}

