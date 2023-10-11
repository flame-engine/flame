import 'dart:math';

final random = Random();

extension RandomExtension on Random {
  double fromRange(double min, double max) =>
      (nextDouble() * (max - min + 1)).floor() + min;
}
