import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Jaw3 extends StatelessWidget {
  const Jaw3({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для нижней челюсти',
      exerciseTitle: 'Имитация жевания с открытым/ закрытым ртом',
      navigationRoute: '/jaw_3_exercises',
    );
  }
}
