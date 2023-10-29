import 'package:flutter/material.dart';
import 'package:flutter_todo_app/screens/tasks_screen_details.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Model/Task.dart';
import '../widgets/taskprovider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.loadTasks(); // Carrega as tarefas do Firestore
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    print("Selected Day: $_selectedDay");
    print("Tasks Count: ${taskProvider.tasks.length}");

    List<Task> tasksForSelectedDay = taskProvider.tasks
        .where(
            (task) => task.date != null && isSameDay(task.date!, _selectedDay))
        .toList();

    print("Tasks for Selected Day: ${tasksForSelectedDay.length}");

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              TableCalendar(
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2050),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay; // Atualiza a data selecionada
                  });
                },
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                  CalendarFormat.week: 'Semana',
                },
                locale: 'pt_BR',
              ),
              // Exibe as tarefas do dia selecionado
              if (tasksForSelectedDay.isNotEmpty)
                Column(
                  children: tasksForSelectedDay.map((task) {
                    return ListTile(
                      title: Text(task.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(task: task),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
