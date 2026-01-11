import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face1 extends StatelessWidget {
  const Face1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Подними брови вверх, удержи',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/face_1_exercises',
    );
  }
}
//f