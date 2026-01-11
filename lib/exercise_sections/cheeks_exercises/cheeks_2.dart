import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Cheeks2 extends StatelessWidget {
  const Cheeks2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для щёк',
      exerciseTitle: 'Втянуть обе щеки',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/cheeks_2_exercises',
    );
  }
}
