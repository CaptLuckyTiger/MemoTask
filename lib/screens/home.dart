import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/ThemeProvider.dart';
import '../widgets/taskprovider.dart';
import '../widgets/todo_item.dart';

import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'config_screen.dart'; // Importe a tela de adição de tarefas

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

  @override
  void initState() {
    _foundToDo = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      drawer: _buildDrawer(), // Adicione o Drawer aqui
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
    if (_currentIndex == 0) {
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
                  child: Consumer<TaskProvider>(
                    builder: (
                      context,
                      taskProvider,
                      child,
                    ) {
                      return ListView.builder(
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.tasks[index];
                          return ToDoItem(
                            todo: ToDo(id: task.title, todoText: task.title),
                            onToDoChanged: _handleToDoChange,
                            onDeleteItem: (id) => _deleteToDoItem(
                                id, taskProvider), // Passa o taskProvider
                          );
                        },
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
      return const CalendarScreen();
    }
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id, TaskProvider taskProvider) {
    setState(() {
      print('Tentando excluir tarefa com ID: $id');
      taskProvider.removeTask(id);
      _foundToDo.removeWhere((task) => task.id == id);
      print('Tarefa removida. Tamanho de _foundToDo: ${_foundToDo.length}');
    });
  }

  void _addToDoItem(String toDo) {
    setState(() {
      todosList.add(ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        todoText: toDo,
      ));
    });
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

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        color: tdBGColor,
      ),
      child: TextField(
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBlue,
      elevation: 0,
      title: const Text('MemoTask'),
      actions: [
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: tdBlue,
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
                const Text(
                  'Seu Nome',
                  style: TextStyle(
                    color: tdBGColor,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'email@example.com',
                  style: TextStyle(
                    color: tdBGColor,
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
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfigScreen(
                      onThemeChanged: updateTheme), // Passegem de função aqui
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void updateTheme(Color primaryColor, Color accentColor, Color backgroundColor,
      Color textColor, Color secondaryColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateTheme(
        primaryColor, accentColor, backgroundColor, textColor, secondaryColor);
  }
}
