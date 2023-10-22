import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'eventdetailsscreen.dart';

class CalendarScreen extends StatefulWidget {
  final Map<DateTime, List<String>> events;

  const CalendarScreen({required this.events});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
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
              onPageChanged: (focusedDay) {
                // No-op
              },
              onDaySelected: (selectedDay, focusedDay) {
                print('Dia selecionado: $selectedDay');
                final eventDetails = widget.events[selectedDay] ?? [];
                print(
                    'Events for Selected Day: $eventDetails'); // Altere esta linha
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(
                      eventDetails: eventDetails,
                    ),
                  ),
                );
              },
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mês',
                CalendarFormat.week: 'Semana',
              },
              locale: 'pt_BR',
              eventLoader: (day) {
                // Filtrar as tarefas com base na data de criação
                final tasksForSelectedDay = widget.events.entries
                    .where((entry) {
                      final taskDate = entry.key;
                      print('Data da tarefa: $taskDate'); // Adicione este log
                      print('Dia selecionado: $day'); // Adicione este log
                      return isSameDay(taskDate, day);
                    })
                    .map((entry) => entry.value)
                    .expand((tasks) => tasks)
                    .toList();
                print(
                    'Tarefas para o dia $day: $tasksForSelectedDay'); // Adicione este log

                return tasksForSelectedDay;
              },
            ),
          ],
        ),
      ),
    );
  }
}
