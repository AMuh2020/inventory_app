
import 'package:inventory_app/models/cart_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:inventory_app/main.dart';
import 'package:path_provider/path_provider.dart';

Future settingsStartUp() async {
  print('Starting up, loading settings');
  // Get the shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Check if the dark mode key exists
  if (!prefs.containsKey('darkMode')) {
    // If it doesn't exist, set it to false
    print('Dark mode key does not exist');
    prefs.setBool('darkMode', globals.defaults['darkMode']);
  } else {
    print('Dark mode key exists');
    print('Dark mode value: ${prefs.getBool('darkMode')}');
    // If it does exist, set the dark mode to the value in the shared preferences
    globals.darkMode = prefs.getBool('darkMode') ?? false;
  }
  
  // Check if the customer info fields key exists
  if (!prefs.containsKey('customerInfoFields')) {
    // If it doesn't exist, set it to false
    print('Customer info fields key does not exist');
    prefs.setBool('customerInfoFields', globals.defaults['customerInfoFields']);
  } else {
    print('Customer info fields key exists');
    print('Customer info fields value: ${prefs.getBool('customerInfoFields')}');
    // If it does exist, set the customer info fields to the value in the shared preferences
    globals.customerInfoFields = prefs.getBool('customerInfoFields') ?? false;
  }
  // Check if the currency symbol key exists
  if (!prefs.containsKey('currencySymbol')) {
    // If it doesn't exist, set it to the default currency symbol
    print('Currency symbol key does not exist');
    prefs.setString('currencySymbol', globals.defaults['currencySymbol']);
  } else {
    print('Currency symbol key exists');
    print('Currency symbol value: ${prefs.getString('currencySymbol')}');
    // If it does exist, set the currency symbol to the value in the shared preferences
    CurrencyProvider().currencySymbol = prefs.getString('currencySymbol')!;
  }

  // Check if the seed color key exists
  if (!prefs.containsKey('themeColor')) {
    // If it doesn't exist, set it to the default color
    print('theme color key does not exist');
    prefs.setString('themeColor', globals.defaults['seedColor']);
  } else {
    print('theme color key exists');
    print('theme color value: ${prefs.getString('themeColor')}');
    // If it does exist, set the seed color to the value in the shared preferences
    globals.hexSeedColor = prefs.getString('themeColor')!;
    globals.seedColor = hexToColor(globals.hexSeedColor);
  }

  // check if the user has premium
  if (!prefs.containsKey('hasPremium')) {
    // If it doesn't exist, set it to false
    print('hasPremium key does not exist');
    prefs.setBool('hasPremium', globals.defaults['hasPremium']);
  } else {
    print('hasPremium key exists');
    print('hasPremium value: ${prefs.getBool('hasPremium')}');
    // If it does exist, set the has premium to the value in the shared preferences
    globals.hasPremium = prefs.getBool('hasPremium') ?? false;
  }

  print('Settings loaded');
}

// Reset all settings to default
Future resetSettings() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('darkMode', globals.defaults['darkMode']);
  globals.darkMode = globals.defaults['darkMode'];
  prefs.setBool('customerInfoFields', globals.defaults['customerInfoFields']);
  globals.customerInfoFields = globals.defaults['customerInfoFields'];
  prefs.setString('currencySymbol', globals.defaults['currencySymbol']);
  globals.currencySymbol = globals.defaults['currencySymbol'];
  prefs.setString('themeColor', globals.defaults['seedColor']);
  globals.hexSeedColor = globals.defaults['seedColor'];
  print('Settings reset');
  return;
}

// give the user premium features
void grantPremium() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasPremium', true);
  globals.hasPremium = true;
  // todo: premium features guide using
}

// format the price to two decimal places
String twoDecimalPlaces(String value) {
  return double.parse(value).toStringAsFixed(2);
}

// Convert hex color (String) to Color type
Color hexToColor(String hexString) {
  hexString = hexString.replaceFirst('#', '').replaceFirst('0x', '');
  if (hexString.length == 6) {
    hexString = 'FF' + hexString; // Add alpha value if not provided
  }
  print('Hex to color: $hexString');
  return Color(int.parse(hexString, radix: 16));
}

// Convert Color type to hex color (String)
String colorToHexString(Color color) {
  return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}


// delete all data from the app
Future<void> deleteAllData() async {
  await deleteDatabaseFile();
  await deleteImages();
  print('All data deleted');
}

// delete all images from the app
Future<void> deleteImages() async {
  // Get the path to the images directory
  final imagesPath = await getApplicationDocumentsDirectory();
  // Delete the images directory
  imagesPath.delete(recursive: true);
  print('Images deleted');
}

Future<void> deleteDatabaseFile() async {
  // Get the path to the database directory
  final dbPath = await getDatabasesPath();
  // Combine the directory path with the database name to get the full path
  final path = join(dbPath, 'inventory_app.db');

  // Delete the database file
  await deleteDatabase(path);
  print('Database deleted');
}

// A generic function to save shared preferences
void saveSharedPref(String key, Type type , dynamic value) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == String) {
      prefs.setString(key, value.toString());
    } else if (type == int) {
      prefs.setInt(key, value);
    } else if (type == bool) {
      prefs.setBool(key, value);
    }
    print('Shared preferences saved $key of type $type with value $value');
  } catch (e) {
    print('Error saving shared preferences: $e');
  }
}