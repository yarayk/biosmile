import 'package:flutter/material.dart';

class FaceExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'face.png', 'route': '/face_1'},
    {'image': 'face.png', 'route': '/face_2'},
    {'image': 'face.png', 'route': '/face_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнения для мимических мышц")),
      body: ListView(
        children: exercises.map((exercise) {
          return Padding(
            padding: const EdgeInsets.all(8.0), // Добавляем отступы
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, exercise['route']!);
              },
              child: Image.asset(
                'assets/image/${exercise['image']}',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}