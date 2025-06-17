import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Additional1 extends StatelessWidget {
  const Additional1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Дополнительные упражнения',
      exerciseTitle: 'Поцокать, как лошадка',
      navigationRoute: '/additional_1_exercises',
    );
  }
}

