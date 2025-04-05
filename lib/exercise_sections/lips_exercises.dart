import 'package:flutter/material.dart';

class LipsExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'lips.png', 'route': '/lips_1'},
    {'image': 'lips.png', 'route': '/lips_2'},
    {'image': 'lips.png', 'route': '/lips_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнения для губ")),
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