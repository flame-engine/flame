import 'dart:math' show Random;
import 'dart:ui';

extension RandomExtension on Random {
  /// Returns a random boolean based on the given [odds].
  bool nextBoolean({double odds = 0.5}) {
    if (odds < 0 || odds > 1) {
      throw ArgumentError.value(odds, 'odds', 'Must be between 0 and 1');
    }
    return nextDouble() < odds;
  }

  /// Returns a random double between [min] (inclusive) and [max] (exclusive),
  /// using a linear probability distribution.
  double nextDoubleBetween(double min, double max) {
    if (min >= max) {
      throw ArgumentError.value(max, 'max', 'Must be greater than min');
    }
    return min + nextDouble() * (max - min);
  }

  /// Returns a random integer between [min] (inclusive) and [max] (exclusive),
  /// using a linear probability distribution.
  int nextIntBetween(int min, int max) {
    if (min >= max) {
      throw ArgumentError.value(max, 'max', 'Must be greater than min');
    }
    return min + nextInt(max - min);
  }

  /// Returns a random color with 1.0 opacity and RGB values between 0 and 255.
  Color nextColor() {
    return Color.fromARGB(
      255,
      nextIntBetween(0, 256),
      nextIntBetween(0, 256),
      nextIntBetween(0, 256),
    );
  }
}
