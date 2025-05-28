import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Lips1 extends StatelessWidget {
  const Lips1({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для губ',
      exerciseTitle: 'Вытянуть губы вперед - трубочкой',
      navigationRoute: '/lips_1_exercises',
    );
  }
}
