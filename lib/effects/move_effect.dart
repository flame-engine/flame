import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import './effects.dart';
import '../position.dart';

double _direction(double p, double d) => (p - d).sign;
double _distance(double a, double b) => (a - b).abs();

class MoveEffect extends PositionComponentEffect {
  Position destination;
  double speed;
  Curve curve;

  double _xOriginal;
  double _xDistance;
  double _xDirection;

  double _yOriginal;
  double _yDistance;
  double _yDirection;

  MoveEffect({
    @required this.destination,
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
      endPosition = destination;
    }

    _xOriginal = component.x;
    _yOriginal = component.y;

    _xDistance = _distance(destination.x, component.x);
    _yDistance = _distance(destination.y, component.y);

    _xDirection = _direction(destination.x, component.x);
    _yDirection = _direction(destination.y, component.y);

    final totalDistance = sqrt(pow(_xDistance, 2) + pow(_yDistance, 2));
    travelTime = totalDistance / speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final double c = curve?.transform(percentage) ?? 1.0;

    component.x = _xOriginal + _xDistance * c * _xDirection;
    component.y = _yOriginal + _yDistance * c * _yDirection;
  }
}
