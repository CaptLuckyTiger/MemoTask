import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';
import 'View/LoginPage.dart';

void main() {
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
