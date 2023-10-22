import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  AddTaskScreenState createState() => AddTaskScreenState();

  final Map<DateTime, List<String>> events;

  AddTaskScreen({required this.events});
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                  hintText: 'Titulo da tarefa', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String newTask = _taskController.text;
          if (newTask.isNotEmpty) {
            DateTime currentDate = DateTime.now();
            String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
            String taskWithDate = '$newTask - $formattedDate';

            print('Data da tarefa criada: $formattedDate'); // Adicione este log

            setState(() {
              widget.events[currentDate] = [
                ...widget.events[currentDate] ?? [],
                taskWithDate
              ];
            });

            _taskController.clear();

            print('Eventos atualizados: ${widget.events}');

            Navigator.pop(context, taskWithDate);
          }
        },
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
