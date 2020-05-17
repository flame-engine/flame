import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import './effects.dart';

class RotationalEffect extends PositionComponentEffect {
  double rotation;
  double speed;
  Curve curve;

  double _originalAngle;
  double _peakAngle;
  double _direction;

  RotationalEffect({
    @required this.rotation,
    @required this.speed,
    this.curve,
    isInfinite = false,
    isAlternating = false,
  }) : super(isInfinite, isAlternating);

  @override
  set component(_comp) {
    super.component = _comp;
    _originalAngle = component.angle;
    _peakAngle = _originalAngle + rotation;
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
