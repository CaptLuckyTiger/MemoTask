import 'package:flutter/material.dart';
import 'package:flutter_todo_app/View/login_page.dart';
import 'package:flutter_todo_app/screens/home.dart';
import 'package:flutter_todo_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importe o pacote shared_preferences

class AuthCheck extends StatefulWidget {
  AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late Future<SharedPreferences>
      _prefs; // Declare uma variável para as SharedPreferences

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance(); // Inicialize as SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(); // Lidar com erro ao carregar SharedPreferences
        } else {
          final SharedPreferences? sharedPreferences = snapshot.data;
          final AuthService auth = Provider.of<AuthService>(context);

          if (auth.isLoading) {
            return loading();
          } else if (sharedPreferences == null || auth.usuario == null) {
            return LoginPage();
          } else {
            return Home();
          }
        }
      },
    );
  }

  Widget loading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget error() {
    return Scaffold(
      body: Center(
        child: Text('Erro ao carregar SharedPreferences'),
      ),
    );
  }
}
