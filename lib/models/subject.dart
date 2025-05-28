// lib/models/subject.dart
import 'dart:ui'; // For Color
import 'package:flutter/material.dart'; // For Colors.blue etc.

class Subject {
  final String id;
  String name;
  String teacherId;
  DateTime examDate; // Primera fecha de examen (obligatoria)
  DateTime? examDate2; // Segunda fecha de examen (opcional, puede ser null)
  List<Map<String, String>> activities;
  Color color;

  Subject({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.examDate,
    this.examDate2, // La segunda fecha ahora es un parámetro opcional
    List<Map<String, String>>? initialActivities,
    Color? initialColor,
  }) : activities = initialActivities ?? [],
       color = initialColor ?? Colors.blue;

  // Método copyWith para crear una nueva instancia de Subject con propiedades modificadas.
  // Esto es muy útil con Provider y el principio de inmutabilidad.
  Subject copyWith({
    String? id,
    String? name,
    String? teacherId,
    DateTime? examDate,
    DateTime?
    examDate2, // Permite actualizar la segunda fecha, incluyendo a null
    List<Map<String, String>>? activities,
    Color? color,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      examDate: examDate ?? this.examDate,
      examDate2:
          examDate2, // Si se pasa null, se establece a null. Si no se pasa, mantiene el valor actual.
      initialActivities: activities ?? this.activities,
      initialColor: color ?? this.color,
    );
  }

  // Método para añadir actividad
  void addActivity(String description, String time) {
    activities.add({'description': description, 'time': time});
  }

  // Método para remover actividad
  void removeActivity(int index) {
    if (index >= 0 && index < activities.length) {
      activities.removeAt(index);
    }
  }

  // Convertir un objeto Subject a un Map (formato JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'examDate': examDate.toIso8601String(), // Convert DateTime a String
      'examDate2':
          examDate2
              ?.toIso8601String(), // Convertir la segunda fecha (si no es null)
      'activities': activities,
      'colorValue': color.value,
    };
  }

  // Crear un objeto Subject desde un Map (formato JSON)
  factory Subject.fromJson(Map<String, dynamic> json) {
    List<dynamic> activitiesJson = json['activities'] ?? [];
    List<Map<String, String>> parsedActivities =
        activitiesJson
            .map((activity) => Map<String, String>.from(activity as Map))
            .toList();

    // Parsear la segunda fecha, manejando el caso de que sea null
    DateTime? parsedExamDate2;
    if (json['examDate2'] != null) {
      parsedExamDate2 = DateTime.parse(json['examDate2'] as String);
    }

    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherId: json['teacherId'] as String,
      examDate: DateTime.parse(json['examDate'] as String),
      examDate2: parsedExamDate2, // Asignar la segunda fecha parseada
      initialActivities: parsedActivities,
      initialColor: Color(json['colorValue'] as int),
    );
  }
}
