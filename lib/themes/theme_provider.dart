import 'package:flutter/material.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Singleton instance
  static final ThemeProvider _instance = ThemeProvider._internal();

  // Factory constructor to return the singleton instance
  factory ThemeProvider() {
    return _instance;
  }

  // Private constructor
  ThemeProvider._internal() {
    _seedColor = globals.seedColor;
    _isDarkMode = globals.darkMode;

    darkMode = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: _seedColor,
      ),
    );

    lightMode = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: _seedColor,
      ),
    );

    _themeData = isDarkMode ? darkMode : lightMode;
  }

  late ThemeData darkMode;
  late ThemeData lightMode;
  late ThemeData _themeData;
  late Color _seedColor;
  late bool _isDarkMode;


  ThemeData get themeData => _themeData;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();  
  }

  // get the seed color from the globals
  Color get seedColor => _seedColor;

  void toggleTheme() {
    print('Toggling theme');
    print('isDarkMode: $_isDarkMode');
    saveIsDarkMode();
    if (isDarkMode) {
      _themeData = lightMode;
    } else {
      _themeData = darkMode;
    }
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  // save the shared preferences
  void saveIsDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDarkMode);
  }
  void changeSeedColor(Color newColor) {
    saveSeedColor();
    print('Changing seed color to $newColor');
    globals.seedColor = newColor;
    _seedColor = newColor;
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
  void saveSeedColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeColor', globals.hexSeedColor);
    print('shared preferences saved: ${prefs.getString('themeColor')}');
  }
}