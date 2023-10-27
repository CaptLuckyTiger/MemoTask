import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;

  ThemeProvider() {
    _currentTheme = _buildDefaultTheme();
  }

  ThemeData _buildDefaultTheme() {
    return ThemeData.light().copyWith(
        // Personalize o tema padrão aqui, se necessário
        );
  }

  ThemeData get currentTheme => _currentTheme;

  void updateTheme(Color primaryColor, Color accentColor, Color backgroundColor,
      Color textColor, Color secondaryColor) {
    _currentTheme = _currentTheme.copyWith(
      primaryColor: primaryColor,
      hintColor: accentColor,
      backgroundColor: backgroundColor,
      textTheme: _currentTheme.textTheme.copyWith(
        bodyText1: TextStyle(color: textColor), // bodyText1 é apenas um exemplo
      ),
      // Personalize outras cores e propriedades do tema conforme necessário
    );

    notifyListeners();
  }
}
