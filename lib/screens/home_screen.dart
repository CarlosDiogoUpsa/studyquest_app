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
// Note: You have SubjectDetailScreen imported twice. One is sufficient.
// import 'package:studyquest_app/screens/subject_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('HomeScreen initState called.');
  }

  @override
  void dispose() {
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
      body: SingleChildScrollView(
        // <--- Wrap the entire Column with SingleChildScrollView
        child: Column(
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
                    :
                    // Remove SizedBox with fixed height and replace ListView.builder with ListView.
                    // When inside SingleChildScrollView, ListView.builder needs to be constrained.
                    // Using ListView.builder without a fixed height in SingleChildScrollView is problematic.
                    // Instead, we can use ListView.shrinkWrap: true with a limited item count or just ListView directly.
                    // For a dynamic list of items, using ListView.builder with a specific height (as you had)
                    // or a `Column` of `TaskItemWidget`s inside `SingleChildScrollView` works.
                    // However, to make the *entire screen* scrollable without nested scrollables,
                    // it's generally better to let the `SingleChildScrollView` manage the primary scroll.
                    //
                    // To handle the "Tareas para Hoy" list effectively without a fixed height and nested scrolling:
                    // Option 1: Convert to a Column of TaskItemWidgets if the list isn't excessively long.
                    // Option 2: Keep ListView.builder with a constraint if you intend for this section to scroll independently.
                    // For the purpose of "mejor todo y no solo zonas especificas", we'll go with option 1, assuming
                    // the number of daily tasks won't be extremely large. If it can be, you'll need a different approach
                    // like a custom scroll view or `NestedScrollView`.
                    Column(
                      // Changed to Column to avoid nested scrolling issues with ListView.builder
                      children:
                          todayTasks
                              .map((task) => TaskItemWidget(task: task))
                              .toList(),
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
            // Similar to the TaskProvider consumer, for "Tus Materias",
            // we will use Column with SubjectCard widgets to allow the SingleChildScrollView to handle scrolling.
            // If the number of subjects can be very large, consider a different UI approach or NestedScrollView.
            subjectProvider.subjects.isEmpty
                ? const Center(child: Text('No hay materias agregadas'))
                : Column(
                  children:
                      subjectProvider.subjects
                          .map((subject) => SubjectCard(subject: subject))
                          .toList(),
                ),
            // Add some padding at the bottom if needed to prevent content from being cut off by the FAB
            const SizedBox(height: 80.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
}
