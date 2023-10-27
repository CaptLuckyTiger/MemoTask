import 'package:flutter/widgets.dart';
import '../Model/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(String taskId) {
    print('Removendo tarefa com ID: $taskId');

    _tasks.removeWhere((task) => task.id == taskId);
    print('Tarefas restantes: $_tasks');
    notifyListeners();
  }
}
