// lib/providers/task_provider.dart

import 'package:flutter/material.dart'; // For TimeOfDay, ChangeNotifier
import 'package:collection/collection.dart'; // For groupBy
import 'package:shared_preferences/shared_preferences.dart'; // For data persistence
import 'dart:convert'; // For json encoding/decoding
import 'package:uuid/uuid.dart'; // For generating unique IDs (add to pubspec.yaml if not already)

import '../models/task.dart'; // Ensure this path is correct for your merged Task model

// Helper function to compare dates ignoring time
bool isSameDate(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final Uuid _uuid = const Uuid(); // Instantiate Uuid for ID generation

  // Constructor: Load tasks when the provider is created
  TaskProvider() {
    _loadTasks();
  }

  // Getter for tasks (returns a copy to prevent external modification)
  List<Task> get tasks => [..._tasks];

  // Get tasks for a specific day (used by Calendar widget)
  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((task) => isSameDate(task.date, day)).toList();
  }

  // Get tasks grouped by date (useful for calendar eventLoader)
  Map<DateTime, List<Task>> get groupedTasks {
    return groupBy(
      _tasks,
      (Task task) =>
          DateTime.utc(task.date.year, task.date.month, task.date.day),
    );
  }

  // --- Persistence Methods ---

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decodedData = json.decode(tasksJson);
      _tasks =
          decodedData
              .map((item) => Task.fromJson(item as Map<String, dynamic>))
              .toList();
      notifyListeners(); // Notify listeners after loading
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString('tasks', encodedData);
  }

  // --- Task Management Methods ---

  // Add a new task (using the merged Task model)
  void addTask({
    required String title,
    String description = '', // Default to empty string
    required String time, // Time as string from Streaks app
    required DateTime date,
    required String subjectId, // Subject ID from Streaks app
    DateTime? dueDate,
    TimeOfDay? flutterTime, // TimeOfDay for UI pickers
    bool isCompleted = false,
  }) {
    final newTask = Task(
      id: _uuid.v4(), // Generate unique ID
      title: title,
      description: description,
      time: time,
      date: date,
      subjectId: subjectId,
      dueDate: dueDate,
      flutterTime: flutterTime,
      isCompleted: isCompleted,
    );
    _tasks.add(newTask);
    _saveTasks(); // Save changes
    notifyListeners();
  }

  // Remove a task by its ID
  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks(); // Save changes
    notifyListeners();
  }

  // Toggle the completion status of a task
  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      _saveTasks(); // Save changes
      notifyListeners();
    }
  }

  // Update an existing task
  void updateTask(Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = updatedTask;
      _saveTasks(); // Save changes
      notifyListeners();
    }
  }

  // Optional: Get a task by ID
  Task? getTaskById(String taskId) {
    return _tasks.firstWhereOrNull((task) => task.id == taskId);
  }
}
