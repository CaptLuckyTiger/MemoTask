import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Import the table_calendar package

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

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
                // Use isso para mudar o estilo do calendario.
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
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mês',
                CalendarFormat.week: 'Semana',
              },
              locale:
                  'pt_BR', // Defina o idioma para português do botão padrão do package table_calender que muda a visualização do calendario para semana ou mês
            ),
          ],
        ),
      ),
    );
  }
}
