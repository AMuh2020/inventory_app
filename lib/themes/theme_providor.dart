import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color seedColor = Colors.purple;

  ThemeProvider() {
    darkMode = ThemeData(
      // brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: seedColor,
      ),
    );

    lightMode = ThemeData(
      // brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: seedColor,
      ),
    );

    _themeData = lightMode;
  }

  late ThemeData darkMode;
  late ThemeData lightMode;
  late ThemeData _themeData;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  void toggleTheme() {
    if (isDarkMode) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
  }
  void changeSeedColor(Color newColor) {
    darkMode = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: newColor,
      ),
    );

    lightMode = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: newColor,
      ),
    );

    _themeData = isDarkMode ? darkMode : lightMode;
    notifyListeners();
  }
}