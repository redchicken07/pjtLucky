import 'package:flutter/services.dart';

class SlashDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < digits.length && index < 8; index++) {
      buffer.write(digits[index]);
      if (index == 3 || index == 5) {
        buffer.write('/');
      }
    }
    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ClockTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < digits.length && index < 4; index++) {
      buffer.write(digits[index]);
      if (index == 1) {
        buffer.write(':');
      }
    }
    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
