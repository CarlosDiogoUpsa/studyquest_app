// lib/screens/home_screen.dart
// ... existing imports ...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyquest_app/models/subject.dart';
import 'package:studyquest_app/providers/subject_provider.dart';
import 'package:studyquest_app/providers/task_provider.dart'; // Import TaskProvider
import 'package:studyquest_app/widget/daili_widget.dart';
import 'package:studyquest_app/widget/streak_widget.dart';
import 'package:studyquest_app/widget/subject_card.dart';
import 'package:studyquest_app/widget/task_item_widget.dart'; // Import TaskItemWidget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState called.');
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build method called.'); // See when HomeScreen rebuilds
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            // Ensure this navigation back to HomeScreen makes it rebuild
            onPressed: () async {
              print('Navigating to calendar...');
              await Navigator.pushNamed(context, '/calendar');
              // After returning from calendar, force a rebuild if needed
              // (Consumer should handle it, but for debug, can check)
              print('Returned from calendar. Checking for updates.');
              // No explicit setState needed here, as Consumer listens
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StreakWidget(),
          const DailyQuest(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tareas para Hoy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              // Ensure DateTime.now() is consistent.
              // It's good practice to get the current date once at the top of build
              // or just before the call, to avoid tiny discrepancies if build takes time.
              final today = DateTime.now();
              print(
                'Consumer for TaskProvider rebuilds. Current date: ${today.toIso8601String().split('T')[0]}',
              );
              final todayTasks = taskProvider.getTasksForDay(today);
              print('Consumer: Found ${todayTasks.length} tasks for today.');

              return todayTasks.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No tienes tareas programadas para hoy.'),
                  )
                  : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                      itemCount: todayTasks.length,
                      itemBuilder:
                          (ctx, index) =>
                              TaskItemWidget(task: todayTasks[index]),
                    ),
                  );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tus Materias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child:
                subjectProvider.subjects.isEmpty
                    ? const Center(child: Text('No hay materias agregadas'))
                    : ListView.builder(
                      itemCount: subjectProvider.subjects.length,
                      itemBuilder:
                          (ctx, index) => SubjectCard(
                            subject: subjectProvider.subjects[index],
                          ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    // ... (Your existing _showAddSubjectDialog method)
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Añadir Materia'),
            content: TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la materia',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (_subjectController.text.isNotEmpty) {
                    final newSubject = Subject(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _subjectController.text,
                      teacherId: '1', // ID por defecto
                      examDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    Provider.of<SubjectProvider>(
                      context,
                      listen: false,
                    ).addSubject(newSubject);
                    _subjectController.clear();
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}
