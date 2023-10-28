import 'package:flutter/material.dart';
import 'package:flutter_todo_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../constants/colors.dart';
import '../widgets/taskprovider.dart';
import '../widgets/todo_item.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart'; // Importe a tela de adição de tarefas

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/task.dart'; // Agora vai

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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Define the Firestore instance

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
        print('Fetched Task: $title, Date: $date');
        return Task(title, date);
      }).toList();

      taskProvider.setTasks(tasks);

      // Agora, configure um Stream para ouvir atualizações em tempo real do Firestore
      _firestore.collection('tasks').snapshots().listen((querySnapshot) {
        final updatedTasks = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title'];
          final date = data['date'].toDate();
          return Task(title, date);
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
      return StreamBuilder<List<Task>>(
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
                        searchBox(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return ToDoItem(
                                todo:
                                    ToDo(id: task.title, todoText: task.title),
                                onToDoChanged: _handleToDoChange,
                                onDeleteItem: (id) => _deleteToDoItem(
                                    id,
                                    Provider.of<TaskProvider>(context,
                                        listen: false)!),
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
              // Trate o caso em que 'tasks' é nulo, se necessário.
              return Center(child: Text('Nenhuma tarefa encontrada.'));
            }
          });
    } else {
      return const CalendarScreen();
    }
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _deleteToDoItem(String id, TaskProvider taskProvider) async {
    await taskProvider.removeTask(id); // Espere a remoção ser concluída
    await taskProvider.loadTasks(); // Atualize a lista após a remoção
  }

  void _addToDoItem(String toDo) async {
    final newTask = Task(toDo, DateTime.now());

    if (newTask.title.isNotEmpty) {
      TaskProvider taskProvider =
          Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addTask(newTask);
      await taskProvider
          .loadTasks(); // Atualize a lista de tarefas após adicionar
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
              }),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              // Implementar depois
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
    );
  }
}
