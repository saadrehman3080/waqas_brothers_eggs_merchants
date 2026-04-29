/// Small string utilities used across views.
class StringHelpers {
  StringHelpers._();

  static String initial(String value, {String fallback = '?'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    return trimmed.characters.first.toUpperCase();
  }
}

extension on String {
  Iterable<String> get characters sync* {
    for (var i = 0; i < length; i++) {
      yield this[i];
    }
  }
}
