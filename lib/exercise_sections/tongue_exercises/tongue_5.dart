import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Tongue5 extends StatelessWidget {
  const Tongue5({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для языка',
      exerciseTitle: 'Облизать губы по кругу',
      navigationRoute: '/tongue_5_exercises',
    );
  }
}
