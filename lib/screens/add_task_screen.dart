import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/task.dart';
import '../constants/colors.dart';
import '../widgets/taskprovider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskController = TextEditingController();
  bool _taskError = false;

  Future<void> _addTask(Task newTask) async {
    TaskProvider taskProvider =
        Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.addTask(newTask);
    await taskProvider.loadTasks(); // Atualize a lista de tarefas após a adição
    Navigator.pop(context);
  }

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
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                prefixIconConstraints: const BoxConstraints(
                  maxHeight: 20,
                  minWidth: 25,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: 'Adicionar Tarefa',
                hintStyle: const TextStyle(color: tdGrey),
                errorText: _taskError
                    ? 'Não é possível criar uma tarefa sem título'
                    : null,
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Task newTask = Task(_taskController.text, DateTime.now());

          if (newTask.title.isNotEmpty) {
            TaskProvider taskProvider =
                Provider.of<TaskProvider>(context, listen: false);
            taskProvider.addTask(newTask);
            Navigator.pop(context);
          } else {
            setState(() {
              _taskError = true;
            });
          }
        },
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
