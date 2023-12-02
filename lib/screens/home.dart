import 'package:flutter/material.dart';
import 'package:flutter_todo_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/taskprovider.dart';
import '../widgets/themeprovider.dart';
import '../widgets/todo_item.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart'; // Importe a tela de adição de tarefas

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Task.dart';

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
  bool isDarkMode = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _resetFilter() {
    setState(() {
      _foundToDo = [];
    });
  }

  void _editToDoItem(String taskId, String updatedTaskText) async {
    TaskProvider taskProvider =
        Provider.of<TaskProvider>(context, listen: false);
    final updatedTask = Task(taskId, updatedTaskText, DateTime.now());

    if (updatedTask.title.isNotEmpty) {
      await taskProvider.editTask(
          taskId, updatedTask); // Chame a função de edição
      await taskProvider
          .loadTasks(); // Atualize a lista de tarefas após a edição
    }
  }

  @override
  void initState() {
    _foundToDo = todosList;
    _fetchTasksFromFirestore();
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
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
        final id = doc.id; // Obtenha o ID do documento
        print('Fetched Task: $title, Date: $date, ID: $id');
        return Task(id, title, date);
      }).toList();

      taskProvider.setTasks(tasks);

      // Agora, configure um Stream para ouvir atualizações em tempo real do Firestore
      _firestore.collection('tasks').snapshots().listen((querySnapshot) {
        final updatedTasks = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id; // Obtenha o ID do documento
          final title = data['title'];
          final date = data['date'].toDate();
          return Task(id, title, date); // Passe o ID corretamente
        }).toList();

        taskProvider.setTasks(updatedTasks);
        // Qualquer outra lógica necessária quando as tarefas são atualizadas pode ser adicionada aqui.
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    // Defina o estado do switch com base no estado do provider
    isDarkMode = darkModeProvider.isDarkMode;
    return Scaffold(
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(),
      drawer: _buildDrawer(isDarkMode), // Adicione o Drawer aqui
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: isDarkMode
                  ? const Color.fromARGB(255, 20, 20, 20)
                  : null, // Aplique a cor do ícone no modo escuro
            ),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month,
              color: isDarkMode
                  ? const Color.fromARGB(255, 20, 20, 20)
                  : null, // Aplique a cor do ícone no modo escuro
            ),
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
                      builder: (context) => const AddTaskScreen()),
                );

                if (newTask != null) {
                  _addToDoItem(newTask);
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
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    if (_currentIndex == 0) {
      return Theme(
        data: theme,
        child: StreamBuilder<List<Task>>(
          stream: Provider.of<TaskProvider>(context, listen: false).loadTasks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final tasks = snapshot.data;
            if (tasks != null) {
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Column(
                      children: [
                        searchBox(isDarkMode),
                        Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return ToDoItem(
                                todo: ToDo(
                                  id: task.id,
                                  todoText: task.title,
                                  date: task.date,
                                ),
                                onToDoChanged: _handleToDoChange,
                                onDeleteItem: (id) => _deleteToDoItem(
                                  id,
                                  Provider.of<TaskProvider>(context,
                                      listen: false),
                                ),
                                onEditItem: (id, newText) => _editToDoItem(
                                    id, newText), // Chamada para edição
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
        ),
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
    await taskProvider.removeTask(taskId); // Espere a remoção ser concluída
    taskProvider.loadTasks(); // Atualize a lista após a remoção
    print('Executou o negócio que deleta?');
  }

  void _addToDoItem(String toDo) async {
    String taskId = UniqueKey().toString(); // Gere um ID único
    final newTask = Task(taskId, toDo, DateTime.now());

    if (newTask.title.isNotEmpty) {
      TaskProvider taskProvider =
          Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addTask(newTask);
      await taskProvider
          .loadTasks(); // Atualize a lista de tarefas após a adição
    }
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];

    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox(bool isDarkMode) {
    final isDarkThemeInput = isDarkMode ? Colors.white : tdBlack;
    final isDarkThemeHint = isDarkMode ? Colors.white : tdGrey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : tdBGColor,
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        style: TextStyle(color: isDarkThemeInput),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkThemeInput,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Pesquisar',
          hintStyle: TextStyle(color: isDarkThemeHint),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode
          ? Colors.black
          : tdBlue, // Use cores diferentes com base no modo claro/escuro
      elevation: 0,
      title: const Text('MemoTask'),
      actions: [
        // Adicione o botão de alternância aqui
        Switch(
            value: isDarkMode,
            onChanged: (value) {
              final darkModeProvider =
                  Provider.of<DarkModeProvider>(context, listen: false);
              darkModeProvider.toggleDarkMode();
            }),
        SizedBox(
          height: 40,
          width: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/images/avatar.jpeg',
              scale: 10,
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
                      child: Image.asset('assets/images/avatar.jpeg'),
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
                }),
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
}
