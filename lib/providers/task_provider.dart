// lib/providers/task_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final Uuid _uuid = const Uuid();

  TaskProvider() {
    print('TaskProvider constructor called. Loading tasks...');
    _loadTasks();
  }

  List<Task> get tasks {
    // print('Getting all tasks. Current count: ${_tasks.length}');
    return [..._tasks];
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Task> getTasksForDay(DateTime day) {
    print('getTasksForDay called for: ${day.toIso8601String().split('T')[0]}');
    final foundTasks =
        _tasks.where((task) => _isSameDate(task.date, day)).toList();
    print('Found ${foundTasks.length} tasks for today.');
    // Optional: Print tasks found
    // for (var task in foundTasks) {
    //   print('  - Task: ${task.title} | Date: ${task.date.toIso8601String().split('T')[0]}');
    // }
    return foundTasks;
  }

  List<Task> getTasksForPeriod(DateTime start, DateTime end) {
    print(
      'getTasksForPeriod called for: ${start.toIso8601String().split('T')[0]} to ${end.toIso8601String().split('T')[0]}',
    );
    final foundTasks =
        _tasks
            .where(
              (task) =>
                  (task.date.isAfter(start.subtract(const Duration(days: 1))) ||
                      _isSameDate(task.date, start)) &&
                  (task.date.isBefore(end.add(const Duration(days: 1))) ||
                      _isSameDate(task.date, end)),
            )
            .toList();
    print('Found ${foundTasks.length} tasks for period.');
    return foundTasks;
  }

  void addTask({
    required String title,
    String description = '',
    required DateTime date,
    String time = 'Sin hora',
    required String subjectId,
    TimeOfDay? flutterTime,
    bool isCompleted = false,
  }) {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      date: date,
      time: time,
      subjectId: subjectId,
      flutterTime: flutterTime,
      isCompleted: isCompleted,
    );
    _tasks.add(newTask);
    print(
      'Task added: ${newTask.title} on ${newTask.date.toIso8601String().split('T')[0]}',
    );
    _saveTasks();
    notifyListeners();
    print(
      'addTask completed. notifyListeners() called. Current tasks count: ${_tasks.length}',
    );
  }

  void updateTask(Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex >= 0) {
      _tasks[taskIndex] = updatedTask;
      print('Task updated: ${updatedTask.title}');
      _saveTasks();
      notifyListeners();
      print(
        'updateTask completed. notifyListeners() called. Current tasks count: ${_tasks.length}',
      );
    } else {
      print('Error: Task with ID ${updatedTask.id} not found for update.');
    }
  }

  void removeTask(String taskId) {
    final initialCount = _tasks.length;
    _tasks.removeWhere((task) => task.id == taskId);
    print('Task removed. Was $initialCount, now ${_tasks.length}');
    _saveTasks();
    notifyListeners();
    print('removeTask completed. notifyListeners() called.');
  }

  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex >= 0) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        isCompleted: !_tasks[taskIndex].isCompleted,
      );
      print('Task completion toggled for ${_tasks[taskIndex].title}');
      _saveTasks();
      notifyListeners();
      print('toggleTaskCompletion completed. notifyListeners() called.');
    }
  }

  // --- Persistence Methods ---
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
    print('Tasks saved to SharedPreferences. ${tasksJson.length} tasks.');
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      _tasks =
          tasksJson
              .map((jsonString) => Task.fromJson(jsonDecode(jsonString)))
              .toList();
      print(
        'Tasks loaded from SharedPreferences. Loaded ${_tasks.length} tasks.',
      );
    } else {
      print('No tasks found in SharedPreferences.');
    }
    notifyListeners(); // Notify after loading to update UI
    print('_loadTasks completed. notifyListeners() called.');
  }
}
