import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import './screens/home.dart';
import 'View/login_page.dart';

void main() {
  // Inicializar data para Português Brasil
  initializeDateFormatting('pt_BR', null).then((_) {
    // Setando localidade português Brasil (pt_BR)
    var locale = const Locale('pt', 'BR');
    Intl.defaultLocale = locale.toString();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoTask',
      home: const Home(),

      initialRoute: '/login', //Rota incial login aparecera primeiro.
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const Home(),
      },
    );
  }
}
