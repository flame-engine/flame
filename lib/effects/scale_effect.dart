import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import 'effects.dart';

double _direction(double p, double d) => (p - d).sign;
double _length(double a, double b) => (a - b).abs();

class ScaleEffect extends PositionComponentEffect {
  Vector2 size;
  double speed;
  Curve curve;

  Vector2 _original;
  Vector2 _diff;
  final Vector2 _dir = Vector2.zero();

  ScaleEffect({
    @required this.size,
    @required this.speed,
    this.curve,
    isInfinite = false,
    isAlternating = false,
    Function onComplete,
  }) : super(isInfinite, isAlternating, onComplete: onComplete);

  @override
  void initialize(_comp) {
    super.initialize(_comp);
    if (!isAlternating) {
      endSize = size.clone();
    }

    _original = component.toSize();
    _diff = Vector2(
      _length(_original.x, size.x),
      _length(_original.y, size.y),
    );

    _dir.x = _direction(size.x, _original.x);
    _dir.y = _direction(size.y, _original.y);

    final scaleDistance = _diff.length;
    travelTime = scaleDistance / speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double c = curve?.transform(percentage) ?? 1.0;
    component.setBySize(_original + (_diff.clone()..multiply(_dir)) * c);
  }
}
