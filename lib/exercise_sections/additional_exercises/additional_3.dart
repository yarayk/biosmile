import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Additional3 extends StatelessWidget {
  const Additional3({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Дополнительные упражнения',
      exerciseTitle: 'Вибрация губ (фыркать)',
      navigationRoute: '/additional_3_exercises',
    );
  }
}
