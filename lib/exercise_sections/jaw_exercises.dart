import 'package:flutter/material.dart';

class JawExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'jaw.png', 'route': '/jaw_1'},
    {'image': 'jaw.png', 'route': '/jaw_2'},
    {'image': 'jaw.png', 'route': '/jaw_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнения для нижней челюсти")),
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