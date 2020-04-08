import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import 'dart:math';

import '../position.dart';
import '../components/component.dart';

abstract class PositionComponentEffect {
  void update(double dt);
  bool hasFinished();
  PositionComponent component;

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

  double _ellapsedTime = 0.0;


  bool _valuesInitted = false;

  MoveEffect({
    @required this.destination,
    @required this.speed,
    this.curve,
  });

  @override
  void update(double dt) {
    if (!_valuesInitted) {
      _xOriginal = component.x;
      _xDistance = (destination.x - component.x).abs();
      final _xTravelTime = _xDistance / speed;
      _xDirection = destination.x < component.x ? - 1 : 1;

      _yOriginal = component.y;
      _yDistance = (destination.y - component.y).abs();
      final _yTravelTime = _yDistance / speed;
      _yDirection = destination.y < component.y ? - 1 : 1;

      _travelTime = max(_xTravelTime, _yTravelTime);

      _valuesInitted = true;
    }

    if (!hasFinished()) {
      final double percent = min(1.0, _ellapsedTime / _travelTime);
      final double c = curve != null ? curve.transform(percent) : 1.0;

      component.x = _xOriginal + _xDistance * c * _xDirection;
      component.y = _yOriginal + _yDistance * c * _yDirection;
    }

    _ellapsedTime += dt;
  }
  @override
  bool hasFinished()  => _ellapsedTime >= _travelTime;
}
