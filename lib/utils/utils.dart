import 'package:intl/intl.dart';
// import 'package:inventory_app/themes/theme_provider.dart';
// import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:flutter/material.dart';

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
    globals.currencySymbol = prefs.getString('currencySymbol')!;
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

Color hexToColor(String hexString) {
  hexString = hexString.replaceFirst('#', '').replaceFirst('0x', '');
  if (hexString.length == 6) {
    hexString = 'FF' + hexString; // Add alpha value if not provided
  }
  print('Hex to color: $hexString');
  return Color(int.parse(hexString, radix: 16));
}
String colorToHexString(Color color) {
  return '0x${color.value.toRadixString(16).padLeft(8, '0')}';
}

void toggleCustomerInfoFields(bool customerInfoField) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('customerInfoFields', customerInfoField);
}

String formatDateTime(String dateTime) {
  DateTime parsedDateTime = DateTime.parse(dateTime);
  return DateFormat('yyyy-MM-dd HH:mm').format(parsedDateTime);
}

String formatDate(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  return DateFormat('yyyy-MM-dd').format(parsedDateTime);
}

String formatTime(String time) {
  DateTime parsedDateTime = DateTime.parse(time);
  return DateFormat('HH:mm').format(parsedDateTime);
}

String dateToDescrptiveString(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  return DateFormat('EEEE, MMMM d, y').format(parsedDateTime);
}

// date to today, yesterday, last week, last month, or older
String dateToHumanReadableString(String date) {
  DateTime parsedDateTime = DateTime.parse(date);
  DateTime now = DateTime.now();
  Duration difference = now.difference(parsedDateTime);
  if (difference.inDays == 0) {
    return 'Today, ${formatTime(date)}';
  } else if (difference.inDays == 1) {
    return 'Yesterday, ${formatTime(date)}';
  } else if (difference.inDays < 7) {
    // day of the week and time
    return '${DateFormat('EEEE').format(parsedDateTime)}, ${formatTime(date)}';
  } else if (difference.inDays > 7 && difference.inDays < 30) {
    return 'Last week';
  } else if (difference.inDays > 30 && difference.inDays < 60) {
    return 'Last month';
  } else {
    return 'Older';
  }
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