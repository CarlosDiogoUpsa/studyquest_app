// lib/models/task.dart

import 'package:flutter/material.dart'; // Needed for TimeOfDay

class Task {
  final String id; // Unique identifier for the task
  String title; // Title of the task
  String description; // Description of the task (can be empty string)
  String
  time; // Time as a string (e.g., "10:00 AM" or "14:30") from the Streaks app
  DateTime date; // The date the task is scheduled for (from Calendar app)
  String subjectId; // ID of the subject this task belongs to (from Streaks app)
  DateTime? dueDate; // Optional due date (from Streaks app), can be null
  TimeOfDay?
  flutterTime; // Optional TimeOfDay object, for Flutter's TimePicker (from Calendar app)
  bool isCompleted; // Whether the task is completed (from Calendar app)

  Task({
    required this.id,
    required this.title,
    this.description = '', // Default to empty string if not provided
    required this.time, // This is the string time
    required this.date,
    required this.subjectId,
    this.dueDate,
    this.flutterTime, // Can be null
    this.isCompleted = false,
  });

  // Method to create a copy of the task with some fields modified
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    DateTime? date,
    String? subjectId,
    DateTime? dueDate,
    TimeOfDay? flutterTime,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      dueDate: dueDate ?? this.dueDate,
      flutterTime: flutterTime ?? this.flutterTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // (Opcional) Métodos para convertir a/desde JSON si planeas guardar las tareas
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time, // Keep as string for original Streaks app compatibility
      'date': date.toIso8601String(), // Save date as ISO string
      'subjectId': subjectId,
      'dueDate':
          dueDate?.toIso8601String(), // Save dueDate as ISO string, can be null
      'flutterTime':
          flutterTime != null
              ? '${flutterTime!.hour}:${flutterTime!.minute}'
              : null, // Save TimeOfDay as string H:M, can be null
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parsedFlutterTime;
    if (json['flutterTime'] != null) {
      final parts = (json['flutterTime'] as String).split(':');
      parsedFlutterTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    DateTime? parsedDueDate;
    if (json['dueDate'] != null) {
      parsedDueDate = DateTime.parse(json['dueDate'] as String);
    }

    return Task(
      id: json['id'],
      title: json['title'],
      description:
          json['description'] ?? '', // Handle potential null for description
      time: json['time'], // This assumes 'time' string is always present
      date: DateTime.parse(json['date']),
      subjectId:
          json['subjectId'], // This assumes 'subjectId' is always present
      dueDate: parsedDueDate,
      flutterTime: parsedFlutterTime,
      isCompleted: json['isCompleted'] ?? false, // Default to false if null
    );
  }
}
