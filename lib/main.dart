import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo_app/screens/home.dart';
import 'package:flutter_todo_app/services/auth_service.dart';
import 'package:flutter_todo_app/widgets/auth_check.dart';
import 'package:flutter_todo_app/widgets/taskprovider.dart';
import 'package:flutter_todo_app/widgets/themeprovider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeDateFormatting('pt_BR', null).then((_) {
    var locale = const Locale('pt', 'BR');
    Intl.defaultLocale = locale.toString();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => DarkModeProvider()),
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
        '/login': (context) => AuthCheck(),
        '/home': (context) => Home(),
      },
    );
  }
}
