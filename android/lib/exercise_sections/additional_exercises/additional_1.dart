import 'package:flutter/material.dart';

class Additional1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Упражнение 1")),
      body: Center(
        child: Text("Страница Additional1", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}