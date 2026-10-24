import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The increments that the gizmo tools snap to while Shift is held.
final snapSettingsProvider = Provider((ref) => const SnapSettings());

@immutable
class const SnapSettings({
  /// The size of the grid that moved components snap to, in the units of
  /// their parent.
  final double moveStep = 8.0,

  /// The angle that rotations snap to multiples of, in radians.
  final double rotateStep = pi / 12,

  /// The value that scales snap to multiples of.
  final double scaleStep = 0.1,
}) {
  double get rotateStepDegrees => rotateStep * 180 / pi;
}

/// Rounds [value] to the nearest multiple of [step].
double snapTo(double value, double step) {
  return (value / step).roundToDouble() * step;
}
