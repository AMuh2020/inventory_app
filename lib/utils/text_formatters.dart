import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final newText = newValue.text;
    final value = double.tryParse(newText);

    if (value == null) {
      return oldValue;
    }

    final parts = newText.split('.');
    if (parts.length > 1 && parts[1].length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}