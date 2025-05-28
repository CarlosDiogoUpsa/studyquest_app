// lib/providers/subject_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Asegúrate de tener esta dependencia
import '../models/subject.dart'; // Asegúrate que la ruta es correcta

class SubjectProvider with ChangeNotifier {
  List<Subject> _subjects = [];
  final Uuid _uuid = const Uuid();

  SubjectProvider() {
    _loadSubjects(); // Cargar materias al inicializar el provider
  }

  List<Subject> get subjects {
    return [
      ..._subjects,
    ]; // Retornar una copia para evitar modificación externa
  }

  // Cargar materias al inicio
  Future<void> initialize() async {
    await _loadSubjects();
  }

  // Método para añadir una nueva materia
  void addSubject({
    required String name,
    String teacherId = '1', // Default ID
    required DateTime examDate,
    DateTime? examDate2, // ¡Nuevo! Segunda fecha de examen
    List<Map<String, String>>? initialActivities,
    Color? color,
  }) {
    final newSubject = Subject(
      id: _uuid.v4(), // Genera un ID único para la nueva materia
      name: name,
      teacherId: teacherId,
      examDate: examDate,
      examDate2: examDate2, // Asignar la segunda fecha
      initialActivities: initialActivities,
      initialColor: color,
    );
    _subjects.add(newSubject);
    _saveSubjects(); // Guardar cambios
    notifyListeners(); // Notificar a los widgets que escuchan
  }

  // Método para actualizar una materia existente
  // Usará el método copyWith del modelo Subject
  void updateSubject(Subject updatedSubject) {
    final index = _subjects.indexWhere((s) => s.id == updatedSubject.id);
    if (index != -1) {
      _subjects[index] = updatedSubject;
      _saveSubjects();
      notifyListeners();
    }
  }

  // Método para eliminar una materia
  void removeSubject(String id) {
    _subjects.removeWhere((subject) => subject.id == id);
    _saveSubjects();
    notifyListeners();
  }

  // Obtener materia por ID
  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((subject) => subject.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- Persistencia ---
  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    // Convertir la lista de objetos Subject a una lista de JSON strings
    final List<String> subjectsJson =
        _subjects.map((subject) => jsonEncode(subject.toJson())).toList();
    await prefs.setStringList('subjects', subjectsJson);
    print('Subjects saved: ${subjectsJson.length} subjects'); // Debug print
  }

  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? subjectsJson = prefs.getStringList('subjects');
    if (subjectsJson != null) {
      // Convertir la lista de JSON strings de vuelta a objetos Subject
      _subjects =
          subjectsJson
              .map((jsonString) => Subject.fromJson(jsonDecode(jsonString)))
              .toList();
      print('Subjects loaded: ${_subjects.length} subjects'); // Debug print
    } else {
      print('No subjects found in SharedPreferences.'); // Debug print
    }
    notifyListeners(); // Notificar para actualizar la UI después de cargar
  }
}
