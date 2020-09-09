import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import 'dart:math';

import './effects.dart';

double _direction(double p, double d) => (p - d).sign;
double _size(double a, double b) => (a - b).abs();

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
      _size(_original.x, size.x),
      _size(_original.y, size.y),
    );

    _dir.x = _direction(size.x, _original.x);
    _dir.y = _direction(size.y, _original.y);

    final scaleDistance = sqrt(pow(_diff.x, 2) + pow(_diff.y, 2));
    travelTime = scaleDistance / speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double c = curve?.transform(percentage) ?? 1.0;

    component.width = _original.x + _diff.x * c * _dir.x;
    component.height = _original.y + _diff.y * c * _dir.y;
  }
}
