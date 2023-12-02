import 'package:flutter/material.dart';
import 'package:flutter_todo_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Adicione esta importação
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/taskprovider.dart';
import '../widgets/themeprovider.dart';
import '../widgets/todo_item.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Task.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  int _currentIndex = 0;
  File? localAvatarImage; // Armazena a referência do arquivo da imagem
  String? localAvatarImagePath; // Caminho da imagem do avatar

  bool isDarkMode = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _resetFilter() {
    setState(() {
      _foundToDo = [];
    });
  }

  @override
  void initState() {
    _fetchTasksFromFirestore();
    _loadAvatarImagePath(); // Carrega o caminho da imagem do avatar ao iniciar
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  Future<void> _loadAvatarImagePath() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedImagePath = prefs.getString('avatarImagePath');

      if (storedImagePath != null && storedImagePath.isNotEmpty) {
        setState(() {
          localAvatarImagePath = storedImagePath;
        });
      }
    } catch (e) {
      print('Error loading avatar image path: $e');
    }
  }

  Future<void> _saveAvatarImagePath(String imagePath) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('avatarImagePath', imagePath);
    } catch (e) {
      print('Error saving avatar image path: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  Future<void> _fetchTasksFromFirestore() async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final querySnapshot = await _firestore.collection('tasks').get();
      final tasks = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title'];
        final date = data['date'].toDate();
        final id = doc.id;
        final imagePath = data['imagePath'] ?? '';
        print(
            'Fetched Task: $title, Date: $date, ID: $id, ImagePath: $imagePath');
        return Task(id, title, date, imagePath: imagePath);
      }).toList();

      taskProvider.setTasks(tasks);

      _firestore.collection('tasks').snapshots().listen((querySnapshot) {
        final updatedTasks = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id;
          final title = data['title'];
          final date = data['date'].toDate();
          return Task(id, title, date);
        }).toList();

        taskProvider.setTasks(updatedTasks);
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    isDarkMode = darkModeProvider.isDarkMode;

    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(),
      drawer: _buildDrawer(isDarkMode),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final newTask = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );

                if (newTask != null) {
                  _addToDoItem(newTask);
                  _fetchTasksFromFirestore();
                }
              },
              elevation: 10,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return StreamBuilder<List<Task>>(
        stream: Provider.of<TaskProvider>(context, listen: false).loadTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data;
          if (tasks != null) {
            List<ToDo> displayedTodos = _foundToDo.isNotEmpty
                ? _foundToDo
                : tasks.map((task) {
                    return ToDo(
                      id: task.id,
                      todoText: task.title,
                    );
                  }).toList();

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      searchBox(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: displayedTodos.length,
                          itemBuilder: (context, index) {
                            final todo = displayedTodos[index];
                            return ToDoItem(
                              todo: todo,
                              onToDoChanged: _handleToDoChange,
                              onDeleteItem: (id) => _deleteToDoItem(
                                id,
                                Provider.of<TaskProvider>(context,
                                    listen: false),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('Nenhuma tarefa encontrada.'));
          }
        },
      );
    } else {
      return const CalendarScreen();
    }
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String taskId, TaskProvider taskProvider) async {
    await taskProvider.removeTask(taskId);
    taskProvider.loadTasks();
    setState(() {
      _runFilter("");
    });
  }

  void _addToDoItem(String toDo) async {
    String taskId = UniqueKey().toString();
    final newTask = Task(taskId, toDo, DateTime.now());

    if (newTask.title.isNotEmpty) {
      TaskProvider taskProvider =
          Provider.of<TaskProvider>(context, listen: false);

      setState(() {
        _foundToDo.add(ToDo(id: newTask.id, todoText: newTask.title));
      });

      await taskProvider.addTask(newTask);

      _searchController.text = '';

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Task> allTasks =
        Provider.of<TaskProvider>(context, listen: false).tasks;
    List<Task> results = [];

    if (enteredKeyword.isEmpty) {
      results = allTasks;
    } else {
      results = allTasks
          .where((task) =>
              task.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      print(enteredKeyword);
    }

    List<ToDo> foundTodos = results.map((task) {
      return ToDo(id: task.id, todoText: task.title);
    }).toList();

    setState(() {
      _foundToDo = foundTodos;
    });
  }

  TextEditingController _searchController = TextEditingController();

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        color: tdBGColor,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Pesquisar',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? Colors.black : tdBlue,
      elevation: 0,
      title: const Text('MemoTask'),
      actions: [
        Switch(
          value: isDarkMode,
          onChanged: (value) {
            final darkModeProvider =
                Provider.of<DarkModeProvider>(context, listen: false);
            darkModeProvider.toggleDarkMode();
          },
        ),
        GestureDetector(
          onTap: () => _pickAvatarImage(),
          child: SizedBox(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: localAvatarImagePath != null
                  ? Image.file(File(localAvatarImagePath!))
                  : Image.asset('assets/images/avatar.jpeg', scale: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(bool isDarkMode) {
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : tdBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: localAvatarImagePath != null
                          ? Image.file(File(localAvatarImagePath!))
                          : Image.asset('assets/images/avatar.jpeg', scale: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Seu Nome',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : tdBGColor,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'email@example.com',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : tdBGColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página Inicial'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthService>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final savedFile = File(pickedFile.path);
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'avatar.jpeg';
        final localAvatarImage =
            await savedFile.copy('${appDir.path}/$fileName');

        await _saveAvatarImagePath(localAvatarImage.path);

        setState(() {
          localAvatarImagePath = localAvatarImage.path;
        });
      } catch (e) {
        print('Error picking avatar image: $e');
      }
    }
  }
}
