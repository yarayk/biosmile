import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Jaw1 extends StatelessWidget {
  const Jaw1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для нижней челюсти',
      exerciseTitle: 'Рот приоткрыть, широко открыть, плотно закрыть',
      navigationRoute: '/jaw_1_exercises',
    );
  }
}


