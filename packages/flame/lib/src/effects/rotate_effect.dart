import 'dart:ui';

import 'package:flutter/animation.dart';

import 'effects.dart';

class RotateEffect extends SimplePositionComponentEffect {
  double angle;
  late double _startAngle;
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
    double? preOffset,
    double? postOffset,
    bool? removeOnFinish,
    VoidCallback? onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          'Either speed or duration necessary',
        ),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          removeOnFinish: removeOnFinish,
          preOffset: preOffset,
          postOffset: postOffset,
          modifiesAngle: true,
          onComplete: onComplete,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _startAngle = affectedParent!.angle;
    _delta = isRelative ? angle : angle - _startAngle;
    if (!isAlternating) {
      endAngle = _startAngle + _delta;
    }
    speed ??= _delta.abs() / duration!;
    duration ??= _delta.abs() / speed!;
    peakTime = isAlternating ? duration! / 2 : duration!;
  }

  @override
  void update(double dt) {
    super.update(dt);
    affectedParent!.angle = _startAngle + _delta * curveProgress;
  }
}
