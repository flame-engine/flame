import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'effects.dart';

class RotateEffect extends SimplePositionComponentEffect {
  double angle;
  double _startAngle;
  double _delta;

  /// Duration or speed needs to be defined
  RotateEffect({
    @required this.angle, // As many radians as you want to rotate
    double duration, // How long it should take for completion
    double speed, // The speed of rotation in radians/s
    Curve curve,
    bool isInfinite = false,
    bool isAlternating = false,
    bool isRelative = false,
    void Function() onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          "Either speed or duration necessary",
        ),
        super(
          isInfinite,
          isAlternating,
          duration: duration,
          speed: speed,
          curve: curve,
          isRelative: isRelative,
          modifiesAngle: true,
          onComplete: onComplete,
        );

  @override
  void initialize(component) {
    super.initialize(component);
    _startAngle = component.angle;
    _delta = isRelative ? angle : angle - _startAngle;
    if (!isAlternating) {
      endAngle = _startAngle + _delta;
    }
    speed ??= _delta / duration;
    duration ??= _delta / speed;
    peakTime = isAlternating ? duration / 2 : duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    component?.angle = _startAngle + _delta * curveProgress;
  }
}
