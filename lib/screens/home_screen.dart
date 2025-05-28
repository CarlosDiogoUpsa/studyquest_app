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
    // Inicializar datos si es necesario
    // Providers are typically initialized in MultiProvider in main.dart
    // No need to check isEmpty here if you rely on main.dart's initialization
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);

    // Get the TaskProvider. We use Consumer for the tasks section to
    // only rebuild that part when tasks change, optimizing performance.
    // If you need tasks data throughout the build method, you can also use:
    // final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Ensure text aligns correctly
        children: [
          const StreakWidget(),
          const DailyQuest(),
          // --- Section for Today's Tasks ---
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
              final todayTasks = taskProvider.getTasksForDay(DateTime.now());
              return todayTasks.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('No tienes tareas programadas para hoy.'),
                  )
                  : SizedBox(
                    // Use a fixed height for tasks to prevent overflow issues
                    // with the Expanded widget below for subjects.
                    // Adjust height based on how many tasks you expect to show.
                    height:
                        MediaQuery.of(context).size.height *
                        0.25, // Example: 25% of screen height
                    child: ListView.builder(
                      itemCount: todayTasks.length,
                      itemBuilder:
                          (ctx, index) =>
                              TaskItemWidget(task: todayTasks[index]),
                    ),
                  );
            },
          ),
          // --- Your existing Subjects Section ---
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
