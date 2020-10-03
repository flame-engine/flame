import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import './effects.dart';

class RotateEffect extends PositionComponentEffect {
  double radians;
  double speed;
  Curve curve;
  double _startAngle;
  double _delta;

  RotateEffect({
    @required this.radians, // As many radians as you want to rotate
    @required this.speed, // In radians per second
    this.curve,
    isInfinite = false,
    isAlternating = false,
    isRelative = false,
    Function onComplete,
  }) : super(
          isInfinite,
          isAlternating,
          isRelative: isRelative,
          onComplete: onComplete,
        );

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    if (!isAlternating) {
      endAngle = _comp.angle + radians;
    }
    _startAngle = component.angle;
    _delta = isRelative ? radians : radians - _startAngle;
    travelTime = (_delta / speed).abs();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double progress = curve?.transform(percentage) ?? 1.0;
    component.angle = _startAngle + _delta * progress;
  }
}
