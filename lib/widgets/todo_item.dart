import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe a classe DateFormat
import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final void Function(ToDo) onToDoChanged; // Especifique o tipo da função aqui
  final void Function(String) onDeleteItem; // Especifique o tipo da função aqui

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          onToDoChanged(todo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.todoText!,
              style: TextStyle(
                fontSize: 16,
                color: tdBlack,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            if (todo.date != null) // Exibir a data se estiver disponível
              Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(todo.date!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: tdGrey,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: tdRed,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
              color: Colors.white,
              iconSize: 18,
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (todo.id != null) {
                  onDeleteItem(todo
                      .id!); // Usando o operador '!' para indicar que o valor não é nulo
                }
              }),
        ),
      ),
    );
  }
}
