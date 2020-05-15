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

  Size _original;
  Size _diff;
  final Position _dir = Position.empty();

  ScaleEffect(
      {@required this.size,
      @required this.speed,
      this.curve,
      isInfinite = false,
      isAlternating = false})
      : super(isInfinite, isAlternating);

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

    final scaleDistance = sqrt(pow(_diff.width, 2) + pow(_diff.height, 2));
    travelTime = scaleDistance / speed;
  }

  @override
  void update(double dt) {
    if (!hasFinished()) {
      final double c = curve?.transform(percentage) ?? 1.0;

      component.width = _original.width + _diff.width * c * _dir.x;
      component.height = _original.height + _diff.height * c * _dir.y;
    }
    super.update(dt);
  }
}
