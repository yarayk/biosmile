import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Cheeks4 extends StatelessWidget {
  const Cheeks4({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для щёк',
      exerciseTitle: 'Чередовать 1 и 2 задание',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/cheeks_4_exercises',
    );
  }
}
            