// lib/screens/home_screen.dart
// ... existing imports ...
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyquest_app/models/subject.dart'; // Asegúrate de que Subject esté actualizado con examDate2 y copyWith
import 'package:studyquest_app/providers/subject_provider.dart'; // Asegúrate de que SubjectProvider esté actualizado
import 'package:studyquest_app/providers/task_provider.dart';
import 'package:studyquest_app/screens/subject_detail.dart';
import 'package:studyquest_app/widget/daili_widget.dart';
import 'package:studyquest_app/widget/streak_widget.dart';
import 'package:studyquest_app/widget/subject_card.dart';
import 'package:studyquest_app/widget/task_item_widget.dart';
import 'package:studyquest_app/screens/subject_detail.dart'; // ¡Importa la nueva pantalla!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ELIMINA ESTE CONTROLADOR si no lo vas a usar para el diálogo.
  // final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState called.');
  }

  @override
  void dispose() {
    // ELIMINA ESTO si _subjectController ya no existe.
    // _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build method called.');
    final subjectProvider = Provider.of<SubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              print('Navigating to calendar...');
              await Navigator.pushNamed(context, '/calendar');
              print('Returned from calendar. Checking for updates.');
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
        onPressed: () {
          // ¡Aquí cambiamos para navegar a la nueva SubjectDetailScreen!
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (ctx) =>
                      const SubjectDetailScreen(), // No pasamos 'subject' para CREAR una nueva.
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ¡ELIMINA COMPLETO EL MÉTODO _showAddSubjectDialog!
  // void _showAddSubjectDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Añadir Materia'),
  //       content: TextField(
  //         controller: _subjectController,
  //         decoration: const InputDecoration(
  //           labelText: 'Nombre de la materia',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Cancelar'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (_subjectController.text.isNotEmpty) {
  //               final newSubject = Subject(
  //                 id: DateTime.now().millisecondsSinceEpoch.toString(),
  //                 name: _subjectController.text,
  //                 teacherId: '1', // ID por defecto
  //                 examDate: DateTime.now().add(const Duration(days: 30)),
  //               );
  //               Provider.of<SubjectProvider>(
  //                 context,
  //                 listen: false,
  //               ).addSubject(newSubject); // ESTA ES LA LÍNEA QUE DABA ERROR
  //               _subjectController.clear();
  //               Navigator.pop(ctx);
  //             }
  //           },
  //           child: const Text('Guardar'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
