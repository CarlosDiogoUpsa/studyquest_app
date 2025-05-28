// lib/widgets/task_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la hora (aunque usaremos MaterialLocalizations ahora)
import 'package:provider/provider.dart';
import 'package:studyquest_app/providers/subject_provider.dart';
import '../screens/task_detail_screen.dart'; // Asegúrate que la ruta sea correcta según tu estructura de carpetas
import '../models/task.dart';
import '../providers/task_provider.dart'; // Lo necesitarás para acciones como completar o eliminar

class TaskItemWidget extends StatelessWidget {
  final Task task;

  const TaskItemWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    String formattedTime = '';

    // --- FIX IS HERE ---
    // Prefer using flutterTime for display if available, as it's a proper TimeOfDay object
    if (task.flutterTime != null) {
      // Use MaterialLocalizations to format TimeOfDay based on device locale settings (e.g., 12hr vs 24hr)
      formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(
        task.flutterTime!,
        alwaysUse24HourFormat:
            false, // Set to true if you always want 24-hour format
      );
    } else if (task.time.isNotEmpty && task.time != 'Sin hora') {
      // Fallback to the original 'time' string if flutterTime is not set
      // (This string was likely formatted during task creation/edit)
      formattedTime = task.time;
    }
    // End of FIX

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            if (value != null) {
              taskProvider.toggleTaskCompletion(task.id);
            }
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            color:
                task.isCompleted
                    ? Colors.grey
                    : Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) // Use .isNotEmpty for String
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  task.description, // description is now non-nullable String
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        task.isCompleted
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            if (formattedTime.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: task.isCompleted ? Colors.grey : Colors.blueGrey,
                  ),
                ),
              ),
            // Display Subject Name if available
            // You'll need SubjectProvider for this, or pass the subject name.
            // For simplicity, I'll add a placeholder that you can expand upon.
            // You could fetch it here or ideally, pass it down from the parent widget.
            // For now, let's just display the subjectId or fetch its name.
            if (task.subjectId.isNotEmpty)
              FutureBuilder<String>(
                future: Future.microtask(() {
                  // Use microtask to avoid direct context.read in build
                  final subjectProvider = Provider.of<SubjectProvider>(
                    context,
                    listen: false,
                  );
                  final subject = subjectProvider.getSubjectById(
                    task.subjectId,
                  );
                  return subject?.name ?? 'Materia desconocida';
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Materia: ${snapshot.data}',
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isCompleted ? Colors.grey : Colors.purple,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Or a loading indicator
                },
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar esta tarea?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Sí',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          taskProvider.removeTask(task.id);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tarea eliminada')),
                          );
                        },
                      ),
                    ],
                  ),
            );
          },
        ),
        onTap: () {
          // Navigate to TaskDetailScreen for editing
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
      ),
    );
  }
}
