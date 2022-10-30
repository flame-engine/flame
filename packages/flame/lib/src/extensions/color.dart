import 'dart:math';
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
  /// The `#` is optional.
  /// The short-hand syntax is support, e.g.: #CCC.
  /// Lower-case letters are supported.
  ///
  /// Examples of valid inputs:
  /// ccc, CCC, #ccc, #CCC, #c1c1c1, #C1C1C1, c1c1c1, C1C1C1
  ///
  /// If the string is not valid, an error is thrown.
  ///
  /// Note: if you are hardcoding colors, use Dart's built-in hexadecimal
  /// literals instead.
  static Color fromRGBHexString(String hexString) {
    if (hexString.length == 3 || hexString.length == 4) {
      return _parseRegex(1, 3, hexString);
    } else if (hexString.length == 6 || hexString.length == 7) {
      return _parseRegex(2, 3, hexString);
    } else {
      throw 'Invalid format for RGB hex string: $hexString';
    }
  }

  /// Parses an ARGB color from a valid hex string (e.g. #1C1C1C).
  ///
  /// The `#` is optional.
  /// The short-hand syntax is support, e.g.: #CCCC.
  /// Lower-case letters are supported.
  ///
  /// Examples of valid inputs:
  /// fccc, FCCC, #fccc, #FCCC, #ffc1c1c1, #FFC1C1C1, ffc1c1c1, FFC1C1C1
  ///
  /// If the string is not valid, an error is thrown.
  ///
  /// Note: if you are hardcoding colors, use Dart's built-in hexadecimal
  /// literals instead.
  static Color fromARGBHexString(String hexString) {
    if (hexString.length == 4 || hexString.length == 5) {
      return _parseRegex(1, 4, hexString);
    } else if (hexString.length == 8 || hexString.length == 9) {
      return _parseRegex(2, 4, hexString);
    } else {
      throw 'Invalid format for ARGB hex string: $hexString';
    }
  }

  static Color _parseRegex(int size, int blocks, String target) {
    final groups = [for (var i = 1; i <= blocks; i++) i];
    final regexBlocks = groups.map((_) => '([0-9a-fA-F]{$size})').join();
    final regex = RegExp('^\\#?$regexBlocks\$');
    final matcher = regex.firstMatch(target)!;
    final extracted = matcher
        .groups(groups)
        .map((e) => e!)
        .map((e) => size == 1 ? '$e$e' : e)
        .map((e) => int.parse(e, radix: 16))
        .toList();
    final components = [if (blocks == 3) 255, ...extracted];
    return Color.fromARGB(
      components[0],
      components[1],
      components[2],
      components[3],
    );
  }

  /// Generates a random [Color] with the set [withAlpha] or the default (1.0).
  /// You can pass in a random number generator [rng], if omitted the function
  /// will create a new [Random] object without a seed and use that.
  /// [base] can be used to get the random colors in only a lighter spectrum, it
  /// should be between 0 and 256.
  static Color random({
    double withAlpha = 1.0,
    int base = 0,
    Random? rng,
  }) {
    assert(
      base >= 0 && base <= 256,
      'The base argument should be in the range 0..256',
    );
    rng ??= Random();
    return Color.fromRGBO(
      base + (base >= 255 ? 0 : rng.nextInt(256 - base)),
      base + (base >= 255 ? 0 : rng.nextInt(256 - base)),
      base + (base >= 255 ? 0 : rng.nextInt(256 - base)),
      withAlpha,
    );
  }
}
