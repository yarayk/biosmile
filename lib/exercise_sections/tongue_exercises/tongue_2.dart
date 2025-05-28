import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Tongue2 extends StatelessWidget {
  const Tongue2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для языка',
      exerciseTitle: 'Рот открыт, язык вверх-вниз',
      navigationRoute: '/tongue_2_exercises',
    );
  }
}


