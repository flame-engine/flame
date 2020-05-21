import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import './effects.dart';

class RotateEffect extends PositionComponentEffect {
  double radians;
  double speed;
  Curve curve;

  double _originalAngle;
  double _peakAngle;
  double _direction;

  RotateEffect({
    @required this.radians, // The angle to rotate to
    @required this.speed, // In radians per second
    this.curve,
    isInfinite = false,
    isAlternating = false,
  }) : super(isInfinite, isAlternating);

  @override
  set component(_comp) {
    super.component = _comp;
    _originalAngle = component.angle;
    _peakAngle = _originalAngle + radians;
    _direction = _peakAngle.sign;
    travelTime = (_peakAngle / speed).abs();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double c = curve?.transform(percentage) ?? 1.0;
    component.angle = _originalAngle + _peakAngle * c * _direction;
  }
}
