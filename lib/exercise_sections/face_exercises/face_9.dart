import 'package:flutter/material.dart';
import 'package:untitled2/exercise_sections/exercise_template.dart';


class Face9 extends StatelessWidget {
  const Face9({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExerciseTemplate(
      categoryTitle: 'Упражнения для мимических мышц',
      exerciseTitle: 'Раздуй ноздри, шевелий носом. Втягивай ноздри',
      navigationRoute: '/face_9_exercises',
    );
  }
}
