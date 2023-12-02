import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Model/Task.dart';
import '../constants/colors.dart';
import '../widgets/taskprovider.dart';
import 'home.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskController = TextEditingController();
  bool _taskError = false;
  File? _image;
  String? _imagePath;

  Future<void> _addTask(Task newTask) async {
    TaskProvider taskProvider =
        Provider.of<TaskProvider>(context, listen: false);

    // Adicione a lógica para carregar a imagem no Firebase Storage
    if (_image != null) {
      String imageName = "${newTask.id}.jpg";
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/$imageName');

      await storageRef.putFile(_image!);

      // Obtém a URL da imagem após o upload
      _imagePath = await storageRef.getDownloadURL();
    }

    // Atualiza a tarefa com a URL da imagem
    newTask.imagePath = _imagePath;

    await taskProvider.addTask(newTask);
    await taskProvider.loadTasks();
    Navigator.pop(context);
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imagePath = pickedFile.path; // Salve o caminho do arquivo
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  prefixIconConstraints: const BoxConstraints(
                    maxHeight: 20,
                    minWidth: 25,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: 'Adicionar Tarefa',
                  hintStyle: const TextStyle(color: tdGrey),
                  errorText: _taskError
                      ? 'Não é possível criar uma tarefa sem título'
                      : null,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: Text('Escolher imagem da galeria'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: Text('Tirar foto'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _image == null ? Container() : Image.file(_image!),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String taskId = UniqueKey().toString();
          Task newTask = Task(
            taskId,
            _taskController.text,
            DateTime.now(),
            imageFile: _image,
          );

          if (newTask.title.isNotEmpty) {
            TaskProvider taskProvider =
                Provider.of<TaskProvider>(context, listen: false);
            await taskProvider.addTask(newTask);
            await taskProvider.loadTasks();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Home()));
          } else {
            setState(() {
              _taskError = true;
            });
          }
        },
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
