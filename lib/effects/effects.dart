import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'dart:math';
import 'dart:ui';

import '../position.dart';
import '../components/component.dart';

abstract class PositionComponentEffect {
  void update(double dt);
  bool hasFinished();
  PositionComponent component;
}

double _direction(double p, double d) => p < d ? -1 : 1;
double _size(double a, double b) => (a - b).abs();

class ScaleEffect extends PositionComponentEffect {
  Size size;
  double speed;
  Curve curve;

  double _scaleTime;
  double _elapsedTime = 0.0;

  Size _original;
  Size _diff;
  final Position _dir = Position(0, 0);

  ScaleEffect({
    @required this.size,
    @required this.speed,
    this.curve,
  });

  @override
  set component(_comp) {
    super.component = _comp;

    _original = Size(component.width, component.height);
    _diff = Size(
      _size(_original.width, size.width),
      _size(_original.height, size.height),
    );

    _dir.x = _direction(size.width, _original.width);
    _dir.y = _direction(size.height, _original.height);

    _scaleTime = max(
      _diff.width / speed,
      _diff.height / speed,
    );
  }

  @override
  void update(double dt) {
    if (!hasFinished()) {
      final double percent = min(1.0, _elapsedTime / _scaleTime);
      final double c = curve != null ? curve.transform(percent) : 1.0;

      component.width = _original.width + _diff.width * c * _dir.x;
      component.height = _original.height + _diff.height * c * _dir.y;
    } else {
      component.width = size.width;
      component.height = size.height;
    }

    _elapsedTime += dt;
  }

  @override
  bool hasFinished() => _elapsedTime >= _scaleTime;
}

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
      final double c = curve != null ? curve.transform(percent) : 1.0;

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
