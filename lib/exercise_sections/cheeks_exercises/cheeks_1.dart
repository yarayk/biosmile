import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Cheeks1 extends StatelessWidget {
  const Cheeks1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для щёк',
      exerciseTitle: 'Надуть обе щеки',
      navigationRoute: '/cheeks_1_exercises',
    );
  }
}
