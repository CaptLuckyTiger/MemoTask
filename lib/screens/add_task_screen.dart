import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  AddTaskScreenState createState() => AddTaskScreenState();

  // Declaração do atributo events
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
            String formattedDate =
                '${currentDate.day}/${currentDate.month}/${currentDate.year}';
            String taskWithDate = '$newTask - $formattedDate';

            // Use o setter para atualizar os eventos
            setState(() {
              widget.events[currentDate] = [
                ...widget.events[currentDate] ?? [],
                taskWithDate
              ];
            });

            // Limpe o campo de texto após adicionar a tarefa
            _taskController.clear();

            // Adicione um print statement para verificar os eventos atualizados
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
