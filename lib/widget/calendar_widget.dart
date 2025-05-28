import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Mantén esta línea, necesaria para initializeDateFormatting
import 'package:intl/date_symbol_data_local.dart'; // Mantén esta línea
import 'package:table_calendar/table_calendar.dart'; // **Usa esta línea principal** para TableCalendar y isSameDay

import '../providers/task_provider.dart';
import 'task_item_widget.dart';
// import '../models/task.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // Use late final for controllers if needed, or just manage state directly
  // CalendarFormat _calendarFormat = CalendarFormat.month; // If you want format switching
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Use nullable DateTime for selected day

  bool _isDateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initialize selected day to today

    // Initialize date formatting asynchronously
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    // Ensure locale data is loaded for table_calendar and DateFormat
    try {
      await initializeDateFormatting('es', null);
    } catch (e) {
      print('Error initializing date formatting: $e');
      // Handle the error, perhaps show a message or use a fallback locale
    }

    if (mounted) {
      setState(() {
        _isDateFormatInitialized = true;
      });
    }
  }

  // Function to get events (tasks) for a specific day
  // This connects table_calendar's eventLoader to your TaskProvider
  List<dynamic> _getEventsForDay(DateTime day) {
    // Assuming taskProvider.getTasksForDay takes DateTime and returns List<Task>
    // If it returns List<dynamic> directly, that's fine too.
    // We just need a list of *something* to indicate events exist for the day.
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    return taskProvider.getTasksForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch or Provider.of with listen: true inside build
    // to rebuild the widget when tasks change.
    final taskProvider = context.watch<TaskProvider>();

    if (!_isDateFormatInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get tasks for the currently selected day
    final tasksForSelectedDay =
        _selectedDay != null
            ? taskProvider.getTasksForDay(_selectedDay!)
            : []; // Handle case where _selectedDay is null (shouldn't happen with initState)

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TableCalendar replaces your custom header and grid
            TableCalendar(
              locale:
                  'es_ES', // Use the locale initialized by initializeDateFormatting
              firstDay: DateTime.utc(2010, 1, 1), // Set a reasonable start date
              lastDay: DateTime.utc(2050, 12, 31), // Set a reasonable end date
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                // Use `isSameDay` to compare dates without time
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Call setState to update the selected day and rebuild the widget
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    // If you want to jump to the selected month when tapping
                    // a day in a different month, update _focusedDay as well:
                    _focusedDay = focusedDay;
                  });
                }
              },
              // If you want to allow switching between month/week view, uncomment below:
              // calendarFormat: _calendarFormat,
              // onFormatChanged: (format) {
              //   if (_calendarFormat != format) {
              //     setState(() {
              //       _calendarFormat = format;
              //     });
              //   }
              // },
              onPageChanged: (focusedDay) {
                // Update focused day when page changes (month/week swipe)
                _focusedDay = focusedDay;
              },
              // Add eventLoader to show markers on days with tasks
              eventLoader: _getEventsForDay,

              // Customize the calendar appearance (optional)
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color:
                      Theme.of(context).primaryColor, // Use app's primary color
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(
                    0.5,
                  ), // Lighter color for today
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  // Decoration for event dots
                  color: Colors.red, // Example color for dots
                  shape: BoxShape.circle,
                  // size: 4.0, // Example size
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.grey[600],
                ), // Style for weekend text
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide the format button
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).primaryColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child:
                  tasksForSelectedDay.isEmpty
                      ? const Center(
                        child: Text("No hay tareas para este día"),
                      ) // Updated text
                      : ListView.builder(
                        itemCount: tasksForSelectedDay.length,
                        itemBuilder:
                            (ctx, index) => TaskItemWidget(
                              task: tasksForSelectedDay[index],
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed your custom build methods as they are replaced by TableCalendar
  // Widget _buildMonthHeader() { ... }
  // Widget _buildWeekdaysHeader() { ... }
  // Widget _buildDaysGrid() { ... }
}
