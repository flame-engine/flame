import 'dart:ui';

import 'package:flutter/animation.dart';

import 'effects.dart';

class RotateEffect extends PositionComponentEffect {
  double angle;
  late double _delta;

  /// Duration or speed needs to be defined
  RotateEffect({
    required this.angle, // As many radians as you want to rotate
    double? duration, // How long it should take for completion
    double? speed, // The speed of rotation in radians/s
    Curve? curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    double? initialDelay,
    double? peakDelay,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          removeOnFinish: removeOnFinish,
          initialDelay: initialDelay,
          peakDelay: peakDelay,
          modifiesAngle: true,
          onComplete: onComplete,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final startAngle = originalAngle!;
    _delta = isRelative ? angle : angle - startAngle;
    peakAngle = startAngle + _delta;
    speed ??= _delta.abs() / duration!;
    duration ??= _delta.abs() / speed!;
    setPeakTimeFromDuration(duration!);
  }

  @override
  void update(double dt) {
    if (isPaused) {
      return;
    }
    super.update(dt);
    if (hasCompleted()) {
      return;
    }
    affectedParent.angle = originalAngle! + _delta * curveProgress;
  }
}
