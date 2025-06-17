import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Additional2 extends StatelessWidget {
  const Additional2({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Дополнительные упражнения',
      exerciseTitle: 'Брать с ладони мелкие куски яблока',
      navigationRoute: '/additional_2_exercises',
    );
  }
}
