import 'package:flutter/material.dart';
import 'package:studyquest_app/models/subject.dart';

class SubjectProvider with ChangeNotifier {
  // Lista de materias
  List<Subject> _subjects = [];

  // Obtener todas las materias
  List<Subject> get subjects {
    return [..._subjects]; // Devolver una copia de la lista
  }

  // Obtener una materia por su id
  Subject getSubjectById(String id) {
    // Devolver el primer Subject que coincida con el id, o lanzar una excepción si no se encuentra
    return _subjects.firstWhere(
      (subject) => subject.id == id,
      orElse: () {
        throw Exception('Subject with ID $id not found');
      },
    );
  }

  // Agregar una nueva materia
  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
  }

  // Actualizar una materia existente
  void updateSubject(Subject subject) {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index >= 0) {
      _subjects[index] = subject;
      notifyListeners();
    } else {
      throw Exception('Subject with ID ${subject.id} not found');
    }
  }

  // Eliminar una materia
  void removeSubject(String id) {
    _subjects.removeWhere((subject) => subject.id == id);
    notifyListeners();
  }

  // Función para inicializar (si es necesario más adelante para la carga inicial de datos)
  void initialize() {
    // Cualquier lógica de inicialización puede ir aquí
  }

  // Método para agregar una actividad a una materia
  void addActivityToSubject(
    String subjectId,
    String activityDescription,
    String activityTime,
  ) {
    final subject = getSubjectById(subjectId); // Obtener la materia por ID
    // Asegurarse de que la actividad no esté vacía
    if (activityDescription.isNotEmpty && activityTime.isNotEmpty) {
      // Aquí se agregaría la lógica para almacenar o manejar actividades dentro de la materia
      // Por ejemplo, podrías agregar una lista de actividades dentro de la clase Subject
      subject.addActivity(activityDescription, activityTime);
      notifyListeners();
    }
  }
}
