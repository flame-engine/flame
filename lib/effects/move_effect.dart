import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import './effects.dart';

class MoveEffect extends PositionComponentEffect {
  Vector2 destination;
  double speed;
  Curve curve;
  Vector2 _startPosition;
  Vector2 _delta;

  MoveEffect({
    @required this.destination,
    @required this.speed,
    this.curve,
    isInfinite = false,
    isAlternating = false,
    isRelative = true,
    Function onComplete,
  }) : super(isInfinite, isAlternating, isRelative: isRelative, onComplete: onComplete);

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    if (!isAlternating) {
      endPosition = destination;
    }
    _startPosition = component.position.clone();
    _delta = isRelative ? destination : destination - _startPosition;
    travelTime = _delta.length / speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double progress = curve?.transform(percentage) ?? 1.0;
    component.setPosition(_startPosition + _delta * progress);
  }
}
