import 'package:elyeter/core/utils/formatters/phone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spaces a Turkmen number in pairs', () {
    expect(PhoneFormatter.display('+99365855873'), '+993 65 85 58 73');
    expect(PhoneFormatter.display('99365000000'), '+993 65 00 00 00');
    expect(PhoneFormatter.display('+993 65 00 00 00'), '+993 65 00 00 00');
  });

  test('leaves other numbers alone', () {
    expect(PhoneFormatter.display('+79991234567'), '+79991234567');
    expect(PhoneFormatter.display(''), '');
  });
}
