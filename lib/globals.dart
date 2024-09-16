
import 'package:flutter/material.dart';
import 'package:inventory_app/utils/utils.dart' as utils;

bool darkMode = false;

bool customerInfoFields = false;

String currencySymbol = '';


bool hasPremium = false;

String hexSeedColor = '';

// colors are store in hex format so shared preferences can store them
Color seedColor = utils.hexToColor(hexSeedColor);

Map<String, dynamic> defaults = {
  'darkMode': false,
  'customerInfoFields': false,
  'currencySymbol': '\$',
  'seedColor': '0xFF9C27B0',
  'version': '1.0.1+8',
  'hasPremium': false,
};