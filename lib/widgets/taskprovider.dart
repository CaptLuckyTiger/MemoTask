import 'package:flutter/widgets.dart';

class TaskProvider with ChangeNotifier {
  List<String> tasks = [];

  void addTask(String task) {
    tasks.add(task);
    notifyListeners();
  }
}
