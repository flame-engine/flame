import 'dart:math' as math;
import 'package:meta/meta.dart';

import '../ai/steer/steerable.dart';
import '../ai/steer/steering_acceleration.dart';
import '../ai/steer/steering_behavior.dart';
import '../extensions/vector2.dart';
import 'position_component.dart';

class SteerableComponent extends PositionComponent implements Steerable {
  Vector2 _linearVelocity = Vector2.zero();
  double _maxLinearSpeed = 0;
  double _maxLinearAcceleration = 0;
  double _angularSpeed = 0;
  double _maxAngularSpeed = 0;
  double _maxAngularAcceleration = 0;
  double _zeroLinearSpeedThreshold = 0.2;

  SteeringBehavior? behavior;
  SteeringAcceleration steering = SteeringAcceleration();

  @mustCallSuper
  @override
  void update(double dt) {
    behavior?.calculateSteering(dt, steering);
    position.x += _linearVelocity.x * dt;
    position.y += _linearVelocity.y * dt;
    angle += _angularSpeed * dt;
    _linearVelocity += steering.linearAcceleration * dt;
    _linearVelocity.clampMagnitude(_maxLinearSpeed);
    _angularSpeed = (_angularSpeed + steering.angularAcceleration * dt)
        .clamp(-_maxAngularAcceleration, _maxAngularAcceleration);
  }

  @override
  Vector2 get linearVelocity => _linearVelocity;

  @override
  double get angularSpeed => _angularSpeed;

  @override
  double get maxLinearSpeed => _maxLinearSpeed;
  set maxLinearSpeed(double value) {
    assert(value >= 0, 'maxLinearSpeed cannot be negative: $value');
    _maxLinearSpeed = value;
  }

  @override
  double get maxLinearAcceleration => _maxLinearAcceleration;
  set maxLinearAcceleration(double value) {
    _maxLinearAcceleration = value;
  }

  @override
  double get maxAngularSpeed => _maxAngularSpeed;
  set maxAngularSpeed(double value) {
    assert(value >= 0, 'maxAngularSpeed cannot be negative: $value');
    _maxAngularSpeed = value;
  }

  @override
  double get maxAngularAcceleration => _maxAngularAcceleration;
  set maxAngularAcceleration(double value) {
    _maxAngularAcceleration = value;
  }

  @override
  double get orientation => angle;

  @override
  double get boundingRadius => math.max(width, height);

  @override
  Vector2 angleToVector(double angle) {
    return Vector2(-math.sin(angle), math.cos(angle));
  }

  @override
  double vectorToAngle(Vector2 vector) {
    return math.atan2(-vector.x, vector.y);
  }

  @override
  double get zeroLinearSpeedThreshold => _zeroLinearSpeedThreshold;

  set zeroLinearSpeedThreshold(double value) {
    assert(value >= 0, 'zeroLinearSpeedThreshold cannot be negative: $value');
    _zeroLinearSpeedThreshold = value;
  }

  @override
  bool tagged = false;
}
