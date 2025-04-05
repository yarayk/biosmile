import 'package:flutter/material.dart';

class CheeksExercisesPage extends StatelessWidget {
  final List<Map<String, String>> exercises = [
    {'image': 'cheeks.png', 'route': '/cheeks_1'},
    {'image': 'cheeks.png', 'route': '/cheeks_2'},
    {'image': 'cheeks.png', 'route': '/cheeks_3'},
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