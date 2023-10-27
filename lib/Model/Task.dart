import 'package:flutter_todo_app/Model/todo.dart';

class Task {
  final String title;
  final DateTime date;
  final ToDo? relatedToDo;

  Task(this.title, this.date,
      [this.relatedToDo]); // Torna o terceiro argumento opcional

  String get id => relatedToDo?.getId() ?? '';
}
