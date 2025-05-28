import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Additional4 extends StatelessWidget {
  const Additional4({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Дополнительные упражнения',
      exerciseTitle: 'Длинное задание',
      navigationRoute: '/additional_4_exercises',
    );
  }
}
