class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  DateTime? date; // Data é opcional

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.date, // Data é opcional
  });

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Teste1', isDone: true),
      ToDo(
        id: '02',
        todoText: 'Teste2',
      ),
      ToDo(id: '03', todoText: 'Teste1', isDone: true, date: DateTime.now()),
    ];
  }
}
