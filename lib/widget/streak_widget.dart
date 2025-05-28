import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyquest_app/providers/streak_provider.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final streakProvider = Provider.of<StreakProvider>(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Racha Actual'),
                Text(
                  '${streakProvider.currentStreak} días',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.local_fire_department, size: 40),
          ],
        ),
      ),
    );
  }
}
