class LoginViewModel {
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira seu nome de usuario';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Insira sua senha';
    } else if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 characteres';
    }
    return null;
  }

  Future<bool> login(String username, String password) async {
    // Resto da logica de login
    // Retorne true se o login for um sucesso, ou retorne false.
    return username == 'testuser' && password == 'testpassword';
  }
}
