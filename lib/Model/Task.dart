import 'package:flutter_todo_app/Model/todo.dart';
import 'dart:io';

class Task {
  final String id;
  final String title;
  final DateTime date;
  final File? imageFile;
  String? imagePath; // Adiciona o campo para armazenar a URL da imagem

  Task(this.id, this.title, this.date, {this.imageFile, this.imagePath});
}
