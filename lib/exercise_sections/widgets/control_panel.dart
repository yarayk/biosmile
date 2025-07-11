// 📁 widgets/control_panel.dart
import 'package:flutter/material.dart';

class ExerciseControlPanel extends StatelessWidget {
  final VoidCallback onInit;
  final VoidCallback? onSave;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ExerciseControlPanel({
    super.key,
    required this.onInit,
    this.onSave,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'init',
            backgroundColor: Colors.green,
            onPressed: () {
              onInit();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Калибровка выполнена."),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("😐", style: TextStyle(fontSize: 24)),
          ),
          if (onSave != null)
            FloatingActionButton(
              heroTag: 'save',
              backgroundColor: Colors.blue,
              onPressed: onSave,
              child: const Text("😐", style: TextStyle(fontSize: 24)),
            ),
          FloatingActionButton(
            heroTag: 'start',
            backgroundColor: Colors.orange,
            onPressed: () {
              onStart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Начали!"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            heroTag: 'stop',
            backgroundColor: Colors.red,
            onPressed: onStop,
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}