class LoginViewModel {
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor informe o seu usuario';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor informe sua senha';
    } else if (value.length < 8) {
      return 'A senha deve possuir ao menos 8 caracteres ';
    }
    return null;
  }

  Future<bool> login(String username, String password) async {
    // futura logica de login
    // Por exemplo requisições ou operaçãoes async
    // Se o login tiver sucesso ele retornara true ou ira retorna falso.
    return username == 'testuser' && password == 'testpassword';
  }
}
