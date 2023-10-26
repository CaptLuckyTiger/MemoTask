import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo_app/View/login_page.dart';
import 'package:flutter_todo_app/screens/home.dart';
import 'package:flutter_todo_app/widgets/taskprovider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializar data para Português Brasil
    initializeDateFormatting('pt_BR', null).then((_) {
      // Setando localidade português Brasil (pt_BR)
      var locale = const Locale('pt', 'BR');
      Intl.defaultLocale = locale.toString();
    });
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Desliga a marca de agua do banner.
      title: 'MemoTask',
      home: const Home(),
      initialRoute: '/login', // Rota inicial, login aparecerá primeiro.
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const Home(),
      },
    );
  }
}

class AppState extends ChangeNotifier {
  String someData = 'Hello from Provider';

  void updateData(String newData) {
    someData = newData;
    notifyListeners();
  }
}
