import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Jaw1 extends StatelessWidget {
  const Jaw1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения длячелюсти',
      exerciseTitle: 'Рот приоткрыть, широко открыть, плотно закрыть',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/jaw_1_exercises',
    );
  }
}


