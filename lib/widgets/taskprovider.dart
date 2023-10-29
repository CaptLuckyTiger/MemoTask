import 'package:flutter/widgets.dart';
import '../Model/Task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TaskProvider() {
    // agora finalmente funciona.
    _firestore.settings = Settings(persistenceEnabled: false);
  }

  List<Task> get tasks => _tasks;

  Future<void> addTask(Task task) async {
    try {
      await _firestore.collection('tasks').add({
        'title': task.title,
        'date': task.date,
      });

      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> removeTask(String taskId) async {
    print(
        'Excluindo a tarefa com o ID: $taskId'); // Imprime o ID da tarefa a ser excluída
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Stream<List<Task>> loadTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task(
          doc.id, // ID
          doc["title"],
          doc["date"].toDate(),
        );
      }).toList();
    });
  }

  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    notifyListeners();
  }
}
