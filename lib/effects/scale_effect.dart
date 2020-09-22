import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import './effects.dart';

class ScaleEffect extends PositionComponentEffect {
  Vector2 size;
  double speed;
  Curve curve;
  Vector2 _startSize;
  Vector2 _delta;

  ScaleEffect({
    @required this.size,
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
      endSize = size.clone();
    }
    _startSize = component.size;
    _delta = isRelative ? size : size - _startSize;
    travelTime = _delta.length / speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double progress = curve?.transform(percentage) ?? 1.0;
    component.setBySize(_startSize + _delta * progress);
  }
}
