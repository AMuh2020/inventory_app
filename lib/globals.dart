
import 'package:flutter/material.dart';
import 'package:inventory_app/utils/utils.dart' as utils;

bool darkMode = false;

bool customerInfoFields = false;

String currencySymbol = '\$';

String version = '1.0.1+8';

bool hasPremium = false;

String hexSeedColor = '0xFF9C27B0';

// colors are store in hex format so shared preferences can store them
Color seedColor = utils.hexToColor(hexSeedColor);

Map<String, dynamic> defaults = {
  'darkMode': darkMode,
  'customerInfoFields': customerInfoFields,
  'currencySymbol': currencySymbol,
  'seedColor': hexSeedColor,
  'version': version,
  'hasPremium': hasPremium,
};