import 'package:flutter/material.dart';

class DailyQuest extends StatelessWidget {
  const DailyQuest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Misión Diaria'),
            SizedBox(height: 8),
            LinearProgressIndicator(value: 0.5),
            SizedBox(height: 8),
            Text('Completa 5 ejercicios de matemáticas'),
          ],
        ),
      ),
    );
  }
}
