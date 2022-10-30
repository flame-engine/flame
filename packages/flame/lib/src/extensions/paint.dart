import 'dart:math';
import 'dart:ui';

import 'package:flame/src/extensions/color.dart';

export 'dart:ui' show Color;

extension PaintExtension on Paint {
  /// Darken the shade of the [Color] in the [Paint] object by the [amount].
  ///
  /// [amount] is a double between 0 and 1.
  ///
  /// Based on: https://stackoverflow.com/a/60191441.
  void darken(double amount) {
    color = color.darken(amount);
  }

  /// Brighten the shade of the [Color] in the [Paint] object by the [amount].
  ///
  /// [amount] is a double between 0 and 1.
  ///
  /// Based on: https://stackoverflow.com/a/60191441.
  void brighten(double amount) {
    color = color.brighten(amount);
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
  static Paint fromRGBHexString(String hexString) {
    final color = ColorExtension.fromRGBHexString(hexString);
    return Paint()..color = color;
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
  static Paint fromARGBHexString(String hexString) {
    final color = ColorExtension.fromARGBHexString(hexString);
    return Paint()..color = color;
  }

  /// Generates a random [Color] in a new [Paint] object with the set
  /// alpha as [withAlpha] or the default (1.0).
  /// You can pass in a random number generator [rng], if omitted the function
  /// will create a new [Random] object without a seed and use that.
  /// [base] can be used to get the random colors in only a lighter spectrum, it
  /// should be between 0 and 256.
  static Paint random({
    double withAlpha = 1.0,
    int base = 0,
    Random? rng,
  }) {
    final color = ColorExtension.random(
      withAlpha: withAlpha,
      base: base,
      rng: rng,
    );
    return Paint()..color = color;
  }
}
