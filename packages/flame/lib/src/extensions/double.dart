import 'dart:math';

import 'package:flame/geometry.dart';

extension DoubleExtension on double {
  /// Converts +-[infinity] to +-[maxFinite].
  /// If it is already a finite value, that is returned.
  double toFinite() {
    if (this == double.infinity) {
      return double.maxFinite;
    } else if (this == -double.infinity) {
      return -double.maxFinite;
    } else {
      return this;
    }
  }

  /// This method normalizes the angle in radians to the range [-π, π].
  ///
  /// If the angle is already within this range, it is returned unchanged.
  double toNormalizedAngle() {
    if (this >= -pi && this <= pi) {
      return this;
    }
    final normalized = this % tau;

    return normalized > pi ? normalized - tau : normalized;
  }
}
