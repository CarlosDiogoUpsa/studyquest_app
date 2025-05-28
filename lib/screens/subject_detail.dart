// lib/screens/subject_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear las fechas de forma legible
import 'package:studyquest_app/models/subject.dart';
import 'package:studyquest_app/providers/subject_provider.dart';
import 'package:provider/provider.dart';

class SubjectDetailScreen extends StatefulWidget {
  // Ahora el constructor recibe el Subject completo (puede ser null si es para crear)
  final Subject? subject;

  const SubjectDetailScreen({super.key, this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  // Usamos controladores para los TextField si los necesitamos,
  // pero para los DatePickers, es mejor manejar las fechas directamente.
  late String _subjectName; // Para almacenar el nombre si se edita
  late DateTime _examDate1; // Primera fecha de examen
  DateTime? _examDate2; // Segunda fecha de examen (puede ser null)

  // Opcional: Controlador para el nombre de la materia si se puede editar
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      // Modo edición: Inicializar con los datos de la materia existente
      _subjectName = widget.subject!.name;
      _examDate1 = widget.subject!.examDate;
      _examDate2 = widget.subject!.examDate2; // Cargar la segunda fecha
      _nameController.text = _subjectName;
    } else {
      // Modo creación: Inicializar con valores por defecto
      _subjectName =
          'Nueva Materia'; // Un valor por defecto para el título temporal
      _examDate1 = DateTime.now(); // Fecha por defecto para el primer examen
      _examDate2 = null; // La segunda fecha inicia como null
      _nameController.text =
          _subjectName; // Establecer el texto inicial del controlador
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Función para abrir el selector de fecha
  Future<void> _pickDate(
    BuildContext context, {
    required bool isFirstExam,
  }) async {
    // Usar la fecha actual para la fecha inicial si aún no se ha seleccionado nada
    DateTime initialDate =
        isFirstExam
            ? _examDate1
            : (_examDate2 ?? _examDate1.add(const Duration(days: 7)));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000), // Rango de fechas
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFirstExam) {
          _examDate1 = pickedDate;
        } else {
          _examDate2 = pickedDate;
        }
      });
    }
  }

  void _saveSubject() {
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );

    // Obtener el nombre actualizado del controlador
    _subjectName = _nameController.text;

    if (widget.subject != null) {
      // Si estamos editando una materia existente
      final updatedSubject = widget.subject!.copyWith(
        name: _subjectName,
        examDate: _examDate1,
        examDate2: _examDate2, // Pasar la segunda fecha (puede ser null)
        // No pasamos activities ni color aquí a menos que también se editen en esta pantalla
        // Si no se pasan, copyWith mantiene los valores existentes.
      );
      subjectProvider.updateSubject(updatedSubject);
    } else {
      // Si estamos creando una nueva materia
      subjectProvider.addSubject(
        name: _subjectName,
        examDate: _examDate1,
        examDate2: _examDate2, // Pasar la segunda fecha (puede ser null)
        // Puedes añadir initialActivities y color si se establecen al crear
      );
    }
    Navigator.of(context).pop(); // Regresar a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject == null ? 'Crear Materia' : _subjectName),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSubject),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para el nombre de la materia
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Materia',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Actualizar el nombre a medida que se escribe
                setState(() {
                  _subjectName = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Selector para la primera fecha de examen
            ListTile(
              title: const Text('Fecha de Examen 1'),
              subtitle: Text(
                DateFormat.yMd().format(_examDate1),
              ), // Formatear fecha
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, isFirstExam: true),
            ),
            const SizedBox(height: 10),

            // Selector para la segunda fecha de examen (opcional)
            ListTile(
              title: const Text('Fecha de Examen 2 (Opcional)'),
              subtitle: Text(
                _examDate2 == null
                    ? 'Seleccionar Fecha'
                    : DateFormat.yMd().format(_examDate2!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_examDate2 !=
                      null) // Mostrar botón para borrar solo si hay fecha
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _examDate2 = null; // Borrar la segunda fecha
                        });
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () => _pickDate(context, isFirstExam: false),
            ),
            const SizedBox(height: 20),

            // Puedes añadir aquí la lógica para "Añadir Actividad" si la materia lo permite
            // y si esta pantalla es el lugar para gestionarlas.
            // Para las actividades, si las quieres editar aquí, tendrías que
            // pasar la lista de actividades al constructor del diálogo de actividades
            // y actualizar _subject.activities después de que se cierre el diálogo.
            // Por simplicidad, no lo incluyo en este ejemplo.
          ],
        ),
      ),
    );
  }
}
