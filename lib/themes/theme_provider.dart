import 'package:flutter/material.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

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

    _themeData = isDarkMode ? darkMode : lightMode;
  }

  late ThemeData darkMode;
  late ThemeData lightMode;
  late ThemeData _themeData;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => globals.darkMode;

  void toggleTheme() {
    savePrefs();
    if (isDarkMode) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    notifyListeners();
  }
  // save the shared preferences
  void savePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDarkMode);
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