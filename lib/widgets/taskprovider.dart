import 'package:flutter/widgets.dart';
import '../Model/Task.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TaskProvider() {
    _firestore.settings = Settings(persistenceEnabled: false);
  }

  List<Task> get tasks => _tasks;

  Future<void> addTask(Task task) async {
    try {
      String imagePath = "";

      if (task.imageFile != null) {
        String imageName = "${task.id}.jpg";

        firebase_storage.Reference storageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images/$imageName');

        await storageRef.putFile(task.imageFile!);

        imagePath = await storageRef.getDownloadURL();
      }

      await _firestore.collection('tasks').add({
        'title': task.title,
        'date': task.date,
        'imagePath': imagePath,
      });

      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> editTask(String taskId, Task updatedTask) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': updatedTask.title,
        'date': updatedTask.date,
      });
      notifyListeners();
    } catch (e) {
      print('Error editing task: $e');
    }
  }

  Future<void> removeTask(String taskId) async {
    try {
      // Recupere a tarefa que será removida
      final task = _tasks.firstWhere((task) => task.id == taskId);

      // Recupere o caminho da imagem antes de excluir a tarefa
      final imagePath = task.imagePath;

      print('Caminho da imagem: $imagePath');

      // Exclua a imagem do Firebase Storage
      if (imagePath != null && imagePath.isNotEmpty) {
        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(imagePath)
            .delete();
      }

      // Exclua o documento da tarefa no Firestore
      await _firestore.collection('tasks').doc(taskId).delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Stream<List<Task>> loadTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task(
          doc.id,
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
