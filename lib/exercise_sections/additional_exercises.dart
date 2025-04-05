import 'package:flutter/material.dart';

class AdditionalExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'additional.png', 'route': '/additional_1'},
    {'image': 'additional.png', 'route': '/additional_2'},
    {'image': 'additional.png', 'route': '/additional_3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнения для щёк")),
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