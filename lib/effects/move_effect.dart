import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'dart:math';

import './effects.dart';
import '../position.dart';

double _direction(double p, double d) => (p - d).sign;
double _size(double a, double b) => (a - b).abs();

class MoveEffect extends PositionComponentEffect {
  Position destination;
  double speed;
  Curve curve;

  double _travelTime;

  double _xOriginal;
  double _xDistance;
  double _xDirection;

  double _yOriginal;
  double _yDistance;
  double _yDirection;

  double _elapsedTime = 0.0;

  MoveEffect({
    @required this.destination,
    @required this.speed,
    this.curve,
  });

  @override
  set component(_comp) {
    super.component = _comp;

    _xOriginal = component.x;
    _yOriginal = component.y;

    _xDistance = _size(destination.x, component.x);
    _yDistance = _size(destination.y, component.y);

    _xDirection = _direction(destination.x, component.x);
    _yDirection = _direction(destination.y, component.y);

    _travelTime = max(
      _xDistance / speed,
      _yDistance / speed,
    );
  }

  @override
  void update(double dt) {
    if (!hasFinished()) {
      final double percent = min(1.0, _elapsedTime / _travelTime);
      final double c = curve?.transform(percent) ?? 1.0;

      component.x = _xOriginal + _xDistance * c * _xDirection;
      component.y = _yOriginal + _yDistance * c * _yDirection;
    } else {
      component.x = destination.x;
      component.y = destination.y;
    }

    _elapsedTime += dt;
  }

  @override
  bool hasFinished() => _elapsedTime >= _travelTime;
}
