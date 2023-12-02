import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  bool get isAuthenticated {
    return usuario != null; // Returns true if user is not null
  }

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _getUser() async {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  Future<void> registrar(String email, String senha, String name) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      await _updateUserName(name); // Update user's display name
      await _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Email já cadastrado');
      }
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      await _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente');
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _getUser();
  }

  Future<void> _updateUserName(String name) async {
    await _auth.currentUser!.updateProfile(displayName: name);
  }

  Future<User?> getUserData() async {
    try {
      await _getUser();
      return usuario;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
