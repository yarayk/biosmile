import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Cheeks3 extends StatelessWidget {
  const Cheeks3({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для щёк',
      exerciseTitle: 'Надуть правую щеку, затем левую',
      navigationRoute: '/cheeks_3_exercises',
    );
  }
}

