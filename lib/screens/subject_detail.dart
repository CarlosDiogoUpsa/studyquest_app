import 'package:flutter/material.dart';
import 'package:studyquest_app/models/subject.dart';
import 'package:studyquest_app/providers/subject_provider.dart';
import 'package:provider/provider.dart';

class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({super.key});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  late Subject _subject;
  final TextEditingController _examDateController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el subject desde los argumentos pasados en la navegación
    final subjectId = ModalRoute.of(context)?.settings.arguments as String?;
    if (subjectId != null) {
      _subject = Provider.of<SubjectProvider>(
        context,
        listen: false,
      ).getSubjectById(subjectId);
      _examDateController.text = _subject.examDate.toString();
    }
  }

  void _updateExamDate() {
    final newDate = DateTime.parse(_examDateController.text);
    setState(() {
      _subject.examDate = newDate;
    });
    Provider.of<SubjectProvider>(
      context,
      listen: false,
    ).updateSubject(_subject);
  }

  @override
  void dispose() {
    _examDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_subject.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles de la Materia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Materia: ${_subject.name}'),
            Text('Profesor: ${_subject.teacherId}'),
            const SizedBox(height: 20),
            Text('Fecha de Examen: ${_subject.examDate.toLocal()}'),
            const SizedBox(height: 20),
            TextField(
              controller: _examDateController,
              decoration: const InputDecoration(
                labelText: 'Cambiar Fecha de Examen',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _subject.examDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _examDateController.text =
                        selectedDate.toLocal().toString();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateExamDate,
              child: const Text('Guardar Nueva Fecha de Examen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para añadir actividades
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Añadir Actividad'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Descripción de la Actividad',
                            ),
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Hora de la Actividad',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Guardar la actividad
                            print('Actividad añadida');
                            Navigator.pop(context);
                          },
                          child: const Text('Añadir Actividad'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Añadir Actividad'),
            ),
          ],
        ),
      ),
    );
  }
}
