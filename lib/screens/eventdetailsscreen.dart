import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {
  final List<String> eventDetails;

  const EventDetailsScreen({required this.eventDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Detalhes da Tarefa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(),
            if (eventDetails.isEmpty) Text('Nenhuma tarefa para este dia.'),
            for (String task in eventDetails)
              ListTile(
                title: Text(task),
              ),
          ],
        ),
      ),
    );
  }
}
