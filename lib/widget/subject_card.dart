// lib/widget/subject_card.dart

import 'package:flutter/material.dart';
import 'package:studyquest_app/models/subject.dart';
import 'package:provider/provider.dart';
import 'package:studyquest_app/providers/subject_provider.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Optionally use the subject's color here
      color: subject.color.withOpacity(
        0.1,
      ), // Example: light background based on subject color
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/subject-detail',
            arguments: subject.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Visual indicator of the subject's color
              Container(
                width: 8, // Width of the color bar
                height: 50, // Height of the color bar
                color: subject.color, // Use the subject's defined color
                margin: const EdgeInsets.only(right: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Próximo examen: ${subject.examDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    // You could also display a count of activities here if desired
                    // Text('${subject.activities.length} actividades'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Eliminar Materia'),
                          content: Text(
                            '¿Estás seguro de que quieres eliminar "${subject.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                subjectProvider.removeSubject(subject.id);
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
