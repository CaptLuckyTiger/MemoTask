import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatefulWidget {
  final ToDo todo;
  final void Function(ToDo) onToDoChanged;
  final void Function(String) onDeleteItem;
  final void Function(String, String) onEditItem; // Adicionado para edição

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
    required this.onEditItem, // Adicionado para edição
  }) : super(key: key);

  @override
  _ToDoItemState createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool _isDone = false;
  bool _isEditing = false; // Novo estado para controlar a edição do texto
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.todo.todoText);
  }

  @override
  void dispose() {
    _editingController
        .dispose(); // Certifique-se de descartar o controlador ao sair do widget
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
        leading: Icon(
          _isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: _isEditing // Mostrar campo de texto durante a edição
            ? TextFormField(
                controller: _editingController,
                onFieldSubmitted: (_) {
                  setState(() {
                    _isEditing = false; // Encerrar o modo de edição ao enviar
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
            // Botão de edição
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
                    _isEditing = !_isEditing; // Alternar o modo de edição
                  });

                  if (_isEditing) {
                    // Enviar a tarefa atualizada após a edição
                    widget.onEditItem(widget.todo.id!, _editingController.text);
                  }
                },
              ),
            ),
            // Botão de exclusão
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
