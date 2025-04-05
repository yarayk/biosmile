import 'package:flutter/material.dart';

class TongueExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'tongue.png', 'route': '/tongue_1'},
    {'image': 'tongue.png', 'route': '/tongue_2'},
    {'image': 'tongue.png', 'route': '/tongue_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнения для языка")),
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