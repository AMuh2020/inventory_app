import 'package:flutter/material.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
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

  // get the dark mode value from the globals
  bool get isDarkMode => globals.darkMode;

  // get the seed color from the globals
  Color get seedColor => globals.seedColor;

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
    
    print('Changing seed color to $newColor');
    globals.seedColor = newColor;
    darkMode = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: newColor,
      ),
    );

    lightMode = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: newColor,
      ),
    );

    _themeData = isDarkMode ? darkMode : lightMode;
    notifyListeners();
  }
}