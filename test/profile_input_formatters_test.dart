import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_app/utils/profile_input_formatters.dart';

void main() {
  test('slash date formatter inserts separators', () {
    const TextEditingValue oldValue = TextEditingValue.empty;
    const TextEditingValue newValue = TextEditingValue(text: '19921007');

    final TextEditingValue formatted = SlashDateTextInputFormatter()
        .formatEditUpdate(oldValue, newValue);

    expect(formatted.text, '1992/10/07');
  });

  test('clock formatter inserts colon', () {
    const TextEditingValue oldValue = TextEditingValue.empty;
    const TextEditingValue newValue = TextEditingValue(text: '1600');

    final TextEditingValue formatted = ClockTextInputFormatter()
        .formatEditUpdate(oldValue, newValue);

    expect(formatted.text, '16:00');
  });
}
