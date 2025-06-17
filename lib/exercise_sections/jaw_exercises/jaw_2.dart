import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Jaw2 extends StatelessWidget {
  const Jaw2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для нижней челюсти',
      exerciseTitle: 'Движения нижней челюстью вперед, назад, вправо, влево, круговые движения',
      navigationRoute: '/jaw_2_exercises',
    );
  }
}


