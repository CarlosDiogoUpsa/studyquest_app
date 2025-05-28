// lib/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart'; // No longer needed here, generated in TaskProvider

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/subject_provider.dart'; // To get list of subjects for dropdown

class TaskDetailScreen extends StatefulWidget {
  final Task? task; // Existing task for editing, or null if new task
  final DateTime? initialDate; // Initial date suggested for a new task

  const TaskDetailScreen({super.key, this.task, this.initialDate});

  // Optional: Define route names if you use them in your Navigator
  static const routeNameAdd = '/add-task';
  static const routeNameEdit = '/edit-task';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // This is the TimeOfDay variable for the picker

  String? _selectedSubjectId; // For associating with a subject
  // bool _isCompleted = false; // Add this if you want to manage completion here

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.task != null) {
      // --- FIX IS HERE ---
      // Modo Edición: Initialize with existing task data
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _selectedTime = widget.task!.flutterTime; // *** Use flutterTime here ***
      _selectedSubjectId = widget.task!.subjectId; // Load existing subjectId
      // _isCompleted = widget.task!.isCompleted; // Initialize if managing completion
    } else {
      // Modo Creación: Initialize with defaults
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = null; // Default to no specific time
      _selectedSubjectId = null; // No subject selected by default
      // _isCompleted = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Date Picker ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale(
        'es',
        'ES',
      ), // Ensure localization support is enabled in main.dart
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // --- Time Picker ---
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale(
            'es',
            'ES',
          ), // Or your preferred locale for the picker
          child: child,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // --- Save Task Logic ---
  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }
    _formKey.currentState!.save();

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Basic validation
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha.')),
      );
      return;
    }
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una materia.')),
      );
      return;
    }

    // Determine the 'time' string from _selectedTime (TimeOfDay?)
    String timeStringForTask;
    if (_selectedTime != null) {
      // Format TimeOfDay to a string like "10:30" or "2:30 PM"
      // Use MediaQuery.of(context).alwaysUse24HourFormat for formatting preference
      final MaterialLocalizations localizations = MaterialLocalizations.of(
        context,
      );
      timeStringForTask = localizations.formatTimeOfDay(
        _selectedTime!,
        alwaysUse24HourFormat: false,
      );
    } else {
      timeStringForTask = 'Sin hora'; // Default string if no time is selected
    }

    if (widget.task != null) {
      // Update existing task
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        time: timeStringForTask, // Update the string time property
        date: _selectedDate!,
        subjectId: _selectedSubjectId!,
        flutterTime: _selectedTime, // Update the TimeOfDay property
        // isCompleted: _isCompleted, // Include if managing completion here
      );
      taskProvider.updateTask(updatedTask);
    } else {
      // Add new task
      taskProvider.addTask(
        title: _titleController.text,
        description: _descriptionController.text,
        time: timeStringForTask, // Use the formatted string time
        date: _selectedDate!,
        subjectId: _selectedSubjectId!,
        flutterTime:
            _selectedTime, // Pass the TimeOfDay for easy retrieval later
        // isCompleted: _isCompleted, // Default to false if not provided
      );
    }
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    // Access subjects from SubjectProvider for the dropdown
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final subjects = subjectProvider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Añadir Tarea' : 'Editar Tarea'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Title Field ---
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Reunión de equipo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un título.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- Description Field ---
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Discutir avances del proyecto X',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // --- Date Picker ---
                Text(
                  'Fecha y Hora:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No seleccionada'
                            : 'Fecha: ${DateFormat.yMMMd('es_ES').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      child: const Text('Elegir Fecha'),
                      onPressed: () => _pickDate(context),
                    ),
                  ],
                ),

                // --- Time Picker ---
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedTime == null
                            ? 'Sin hora específica'
                            : 'Hora: ${MaterialLocalizations.of(context).formatTimeOfDay(_selectedTime!, alwaysUse24HourFormat: false)}',
                      ),
                    ),
                    TextButton(
                      child: const Text('Elegir Hora'),
                      onPressed: () => _pickTime(context),
                    ),
                    if (_selectedTime != null) // Option to clear time
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Subject Dropdown ---
                Text(
                  'Materia:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona una materia',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      subjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona una materia.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- Save Button ---
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.task == null ? 'Crear Tarea' : 'Guardar Cambios',
                    ),
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
