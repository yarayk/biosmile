import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Tongue3 extends StatelessWidget {
  const Tongue3({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для языка',
      exerciseTitle: 'Рот открыть, язык к правому уху, к левому',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/tongue_3_exercises',
    );
  }
}

