import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'dart:ui';
import 'dart:math';

import './effects.dart';
import '../position.dart';

double _direction(double p, double d) => (p - d).sign;
double _size(double a, double b) => (a - b).abs();

class ScaleEffect extends PositionComponentEffect {
  Size size;
  double speed;
  Curve curve;

  double _scaleTime;
  double _elapsedTime = 0.0;

  Size _original;
  Size _diff;
  final Position _dir = Position.empty();

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
      final double c = curve?.transform(percent) ?? 1.0;

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
