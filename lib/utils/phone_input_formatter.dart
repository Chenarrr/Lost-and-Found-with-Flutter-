import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) return newValue.copyWith(text: '');
    if (text.length > 11) return oldValue;

    final formatted = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 4 || i == 7 || i == 9) {
        formatted.write(' ');
      }
      formatted.write(text[i]);
    }

    return newValue.copyWith(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
