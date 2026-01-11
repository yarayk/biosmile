import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face2 extends StatelessWidget {
  const Face2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Нахмурь брови, удержи',
      exerciseGoal: 'Тренировка мышц век, увлажнение роговицы, улучшение координации.',
      navigationRoute: '/face_2_exercises',
    );
  }
}
