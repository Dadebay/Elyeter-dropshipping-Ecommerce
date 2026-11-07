/// Shows a phone number the way the design does: `+993 65 00 00 00`.
abstract final class PhoneFormatter {
  static final _turkmen = RegExp(r'^\+?993(\d{2})(\d{2})(\d{2})(\d{2})$');

  /// A Turkmen number (`+993XXXXXXXX`, spaces and dashes ignored) is spaced as
  /// `+993 XX XX XX XX`. Anything else comes back unchanged.
  static String display(String phone) {
    final compact = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    final m = _turkmen.firstMatch(compact);
    if (m == null) return phone;
    return '+993 ${m[1]} ${m[2]} ${m[3]} ${m[4]}';
  }
}
