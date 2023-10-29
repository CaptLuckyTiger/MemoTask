import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatefulWidget {
  final ToDo todo;
  final void Function(ToDo) onToDoChanged;
  final void Function(String) onDeleteItem;

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  _ToDoItemState createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool _isDone = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          setState(() {
            _isDone = !_isDone;
          });
          widget.onToDoChanged(widget.todo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          _isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.todo.todoText!,
              style: TextStyle(
                fontSize: 16,
                color: tdBlack,
                decoration: _isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            if (widget.todo.date != null)
              Text(
                'Data: ${DateFormat('yyyy-MM-dd').format(widget.todo.date!)}',
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
              if (widget.todo.id != null) {
                widget.onDeleteItem(widget.todo.id!);
              }
            },
          ),
        ),
      ),
    );
  }
}
