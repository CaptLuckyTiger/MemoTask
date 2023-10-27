import 'package:flutter/material.dart';
import '../Model/task.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  TaskDetailsScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título da Tarefa: ${task.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Data da Tarefa: ${task.date.toLocal()}',
              style: TextStyle(fontSize: 16),
            ),
            //  adicionar mais informações da tarefa, se necessário.
          ],
        ),
      ),
    );
  }
}
