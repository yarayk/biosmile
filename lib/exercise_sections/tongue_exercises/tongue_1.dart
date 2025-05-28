import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Tongue1 extends StatelessWidget {
  const Tongue1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для языка',
      exerciseTitle: 'Открыть рот, язык поднять, опустить',
      navigationRoute: '/tongue_1_exercises',
    );
  }
}

