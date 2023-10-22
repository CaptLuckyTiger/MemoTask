import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'eventdetailsscreen.dart';

//import 'eventdetailsscreen.dart'; // Import the table_calendar package

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
        backgroundColor: Colors.blue, // Cor azul do calendario
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
                print('Events for Selected Day: ${widget.events[selectedDay]}');
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
                // Defina a data sem informações de horário para garantir compatibilidade com o mapa de eventos
                final dateWithoutTime = DateTime(day.year, day.month, day.day);

                // Use a data sem informações de horário para carregar as tarefas associadas a um dia
                return widget.events[dateWithoutTime] ?? [];
              },
            ),
          ],
        ),
      ),
    );
  }
}
