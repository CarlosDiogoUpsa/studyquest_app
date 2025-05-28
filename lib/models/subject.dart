// lib/models/subject.dart

import 'dart:ui'; // For Color
import 'package:flutter/material.dart'; // For Colors.blue etc.

class Subject {
  final String id;
  String name; // Changed to non-final to allow updates if needed
  String teacherId;
  DateTime examDate;
  List<Map<String, String>> activities; // Changed to non-final
  Color color; // Added as a property

  Subject({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.examDate,
    List<Map<String, String>>? initialActivities, // Optional initial activities
    Color? initialColor, // Optional initial color
  })  : activities = initialActivities ?? [], // Initialize activities
        color = initialColor ?? Colors.blue; // Default color if not provided

  // Method to add activity
  void addActivity(String description, String time) {
    activities.add({'description': description, 'time': time});
  }

  // Method to remove activity
  void removeActivity(int index) {
    if (index >= 0 && index < activities.length) {
      activities.removeAt(index);
    }
  }

  // Convert a Subject object into a Map (JSON format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'examDate': examDate.toIso8601String(), // Convert DateTime to String
      'activities': activities,
      'colorValue': color.value, // Store color as an int value
    };
  }

  // Create a Subject object from a Map (JSON format)
  factory Subject.fromJson(Map<String, dynamic> json) {
    List<dynamic> activitiesJson = json['activities'] ?? [];
    List<Map<String, String>> parsedActivities = activitiesJson
        .map((activity) => Map<String, String>.from(activity as Map))
        .toList();

    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherId: json['teacherId'] as String,
      examDate: DateTime.parse(json['examDate'] as String), // Parse String back to DateTime
      initialActivities: parsedActivities,
      initialColor: Color(json['colorValue'] as int), // Reconstruct Color from int
    );
  }
}