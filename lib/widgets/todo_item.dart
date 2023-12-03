import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatefulWidget {
  final ToDo todo;
  final void Function(ToDo) onToDoChanged;
  final void Function(String) onDeleteItem;
  final void Function(String, String) onEditItem; // Added for editing

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    required this.onEditItem, // Added for editing
  }) : super(key: key);

  @override
  _ToDoItemState createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool _isDone = false;
  bool _isEditing = false; // New state to control text editing
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.todo.todoText);
  }

  @override
  void dispose() {
    _editingController
        .dispose(); // Make sure to dispose of the controller when leaving the widget
    super.dispose();
  }

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
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _isDone ? tdBlue : Colors.transparent,
            border: Border.all(
              color: tdBlue,
              width: 2,
            ),
          ),
          child: Center(
            child: _isDone
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        ),
        title: _isEditing // Show text field during editing
            ? TextFormField(
                controller: _editingController,
                onFieldSubmitted: (_) {
                  setState(() {
                    _isEditing = false; // End editing mode on submit
                  });

                  widget.onEditItem(widget.todo.id!, _editingController.text);
                },
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: tdBlack),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              )
            : Column(
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: tdRed,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Colors.white,
                iconSize: 18,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing; // Toggle editing mode
                  });

                  if (_isEditing) {
                    // Submit the updated task after editing
                    widget.onEditItem(widget.todo.id!, _editingController.text);
                  }
                },
              ),
            ),
            // Delete button
            Container(
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
          ],
        ),
      ),
    );
  }
}
