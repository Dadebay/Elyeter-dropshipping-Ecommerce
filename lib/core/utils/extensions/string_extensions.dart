extension StringX on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(trim());

  /// Turkmen mobile numbers, digits only, 8–15 chars.
  bool get isValidPhone =>
      RegExp(r'^\+?\d{8,15}$').hasMatch(replaceAll(' ', ''));

  String? get nullIfEmpty => trim().isEmpty ? null : this;
}
