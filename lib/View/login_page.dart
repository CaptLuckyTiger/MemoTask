import 'package:flutter/material.dart';
import '../View/home_page.dart'; // Importe a classe Home do arquivo home_page.dart
import '../ViewModel/login_view_model.dart';

class LoginPage extends StatelessWidget {
  final LoginViewModel viewModel = LoginViewModel();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Login'),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                  ),
                  validator: viewModel.validateUsername,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                  ),
                  validator: viewModel.validatePassword,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      final loginSuccessful =
                          await viewModel.login(username, password);
                      if (loginSuccessful) {
                        // Navegue para a tela Home do arquivo home_page.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Usuário ou senha incorretos'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Entrar'),
                ),
                TextButton(
                  onPressed: () {
                    // Lógica de recuperação de senha
                  },
                  child: const Text('Esqueceu a senha?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
