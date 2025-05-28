// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Para acceder a TaskProvider si es necesario aquí
import '../widget/calendar_widget.dart'; // Asegúrate que la ruta es correcta
import 'task_detail_screen.dart'; // Para navegar a la pantalla de detalle/creación de tarea
import '../providers/task_provider.dart'; // Para pasar el selectedDay al crear una tarea
import '../models/task.dart'; // Si necesitas el tipo Task

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static const routeName = '/calendar'; // Opcional: para rutas nombradas

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Nota: Tu CalendarWidget actual maneja su propio _selectedDay y _focusedDay internamente.
  // Si quisieras que el FAB use el día seleccionado en CalendarWidget para una nueva tarea,
  // necesitarías "levantar el estado" de _selectedDay y _focusedDay de CalendarWidget
  // a este CalendarScreen, o usar un callback/ValueNotifier.

  // Para este ejemplo, el FAB simplemente abrirá la pantalla de nueva tarea,
  // y TaskDetailScreen puede usar DateTime.now() por defecto o su propio selector de fecha.
  // O, si el CalendarWidget expone de alguna forma el día seleccionado (ej. a través de un GlobalKey
  // o un callback al seleccionar día que actualice una variable aquí), podrías pasarlo.

  // Alternativa más simple: Si el CalendarWidget actualiza un 'selectedDay' en TaskProvider
  // o si hacemos que CalendarWidget acepte un callback que actualice una variable aquí.
  DateTime _currentSelectedDayForNewTask = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Si quieres que el FAB use la fecha actualmente seleccionada en el CalendarWidget,
    // necesitarás que CalendarWidget exponga esa fecha.
    // Una forma es modificar CalendarWidget para que tenga un callback onDaySelected
    // que actualice _currentSelectedDayForNewTask en este _CalendarScreenState.

    // Por ahora, vamos a asumir que CalendarWidget es el que has proporcionado.
    // Tu CalendarWidget ya tiene un Scaffold interno. Si prefieres un Scaffold aquí,
    // puedes quitar el Scaffold de CalendarWidget y ponerlo aquí.

    // Si CalendarWidget NO tiene su propio Scaffold y AppBar:
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Tareas'),
        // Puedes añadir acciones aquí si es necesario
      ),
      body: CalendarWidget(
        // Si has modificado CalendarWidget para que acepte `onDaySelectedCallback`:
        // onDaySelectedForScreen: (selectedDay) {
        //   setState(() {
        //     _currentSelectedDayForNewTask = selectedDay;
        //   });
        // },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Cuando se presiona el FAB, navegamos a TaskDetailScreen.
          // Aquí decidimos si pasamos una fecha inicial.
          // Si _currentSelectedDayForNewTask se actualiza correctamente desde CalendarWidget, úsalo.
          // De lo contrario, TaskDetailScreen puede usar DateTime.now() o permitir escoger.

          // Para pasar el _selectedDay de tu CalendarWidget actual, necesitarías una
          // forma de accederlo (GlobalKey o refactorización de CalendarWidget).
          // Por simplicidad, si no tienes ese mecanismo, puedes no pasar `initialDate`
          // y `TaskDetailScreen` usará `DateTime.now()`.

          // Ejemplo si PUDIERAS obtener el _selectedDay del CalendarWidget:
          // DateTime? initialDateForNewTask = Provider.of<TaskProvider>(context, listen: false).getSelectedDayFromCalendar();
          // O si CalendarWidget tuviera un GlobalKey:
          // DateTime? initialDateForNewTask = _calendarWidgetKey.currentState?.getSelectedDay();

          // Navegamos a TaskDetailScreen para AÑADIR una nueva tarea.
          // No pasamos una tarea existente, lo que indica que es para crear.
          // Podríamos pasar la fecha seleccionada en el calendario si la tuviéramos aquí.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => TaskDetailScreen(
                    // Si CalendarWidget expone su _selectedDay y este screen lo conoce:
                    // initialDate: _currentSelectedDayForNewTask,
                    // De lo contrario, TaskDetailScreen usará su lógica para la fecha inicial.
                  ),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
