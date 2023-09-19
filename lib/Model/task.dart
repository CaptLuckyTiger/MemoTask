class Task {
  String? id;
  String? taskTitle;
  bool isDone;
  DateTime? date;

  Task({
    required this.id,
    required this.taskTitle,
    this.isDone = false,
    this.date,
  });

  static List<Task> todoList() {
    return [
      Task(id: '01', taskTitle: 'Teste1', isDone: true),
      Task(id: '02', taskTitle: 'Teste2'),
      Task(id: '03', taskTitle: 'Teste1', isDone: true, date: DateTime.now()),
    ];
  }
}
