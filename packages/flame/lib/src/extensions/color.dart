import 'dart:ui';

export 'dart:ui' show Color;

extension ColorExtension on Color {
  /// Darken the shade of the color by the [amount].
  ///
  /// [amount] is a double between 0 and 1.
  ///
  /// Based on: https://stackoverflow.com/a/60191441.
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);

    final f = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }

  /// Brighten the shade of the color by the [amount].
  ///
  /// [amount] is a double between 0 and 1.
  ///
  /// Based on: https://stackoverflow.com/a/60191441.
  Color brighten(double amount) {
    assert(amount >= 0 && amount <= 1);

    return Color.fromARGB(
      alpha,
      red + ((255 - red) * amount).round(),
      green + ((255 - green) * amount).round(),
      blue + ((255 - blue) * amount).round(),
    );
  }

  /// Parses an RGB color from a valid hex string (e.g. #1C1C1C).
  ///
  /// If the string is not valid, an error is thrown.
  static Color fromHexString(String hexString) {
    final regex = RegExp('\\#(.{2})(.{2})(.{2})');
    final m = regex.firstMatch(hexString)!;
    final r = int.parse(m.group(1)!, radix: 16);
    final g = int.parse(m.group(2)!, radix: 16);
    final b = int.parse(m.group(3)!, radix: 16);
    return Color.fromARGB(255, r, g, b);
  }
}
