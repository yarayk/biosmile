import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face5 extends StatelessWidget {
  const Face5({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Двигай глазным яблоком, закрыв глаза',
      navigationRoute: '/face_5_exercises',
    );
  }
}
