import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';

void main() {
  late PhoneInputFormatter formatter;

  setUp(() {
    formatter = PhoneInputFormatter();
  });

  TextEditingValue format(String text) {
    return formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: text),
    );
  }

  group('PhoneInputFormatter', () {
    test('empty input returns empty', () {
      final result = format('');
      expect(result.text, '');
    });

    test('formats 3-digit prefix correctly', () {
      final result = format('750');
      expect(result.text, '750');
    });

    test('adds space after 3rd digit', () {
      final result = format('7501');
      expect(result.text, '750 1');
    });

    test('formats 6 digits with two spaces', () {
      final result = format('750222');
      expect(result.text, '750 222');
    });

    test('adds space after 6th digit', () {
      final result = format('7502223');
      expect(result.text, '750 222 3');
    });

    test('formats 8 digits with three spaces', () {
      final result = format('75022234');
      expect(result.text, '750 222 34');
    });

    test('formats full 10-digit number correctly', () {
      final result = format('7502223444');
      expect(result.text, '750 222 34 44');
    });

    test('strips non-digit characters', () {
      final result = format('750-222-3444');
      expect(result.text, '750 222 34 44');
    });

    test('rejects more than 10 digits', () {
      const old = TextEditingValue(text: '750 222 34 44');
      final result = formatter.formatEditUpdate(
        old,
        const TextEditingValue(text: '75022234445'),
      );
      expect(result.text, '750 222 34 44');
    });

    test('cursor position is at end after formatting', () {
      final result = format('7502223444');
      expect(result.selection.baseOffset, '750 222 34 44'.length);
    });
  });
}
