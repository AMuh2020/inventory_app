
import 'package:flutter/material.dart';
import 'package:inventory_app/utils/utils.dart' as utils;

bool darkMode = false;

bool customerInfoFields = false;

String currencySymbol = '';


bool hasPremium = false;

String hexSeedColor = '';

// colors are store in hex format so shared preferences can store them
Color seedColor = utils.hexToColor(defaults['seedColor']);

Map<String, dynamic> defaults = {
  'darkMode': false,
  'customerInfoFields': false,
  'currencySymbol': '\$',
  'seedColor': '0xFF9C27B0',
  'version': '2.0.0',
  'hasPremium': false,
};