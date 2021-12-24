import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../ai/steer/steerable.dart';
import '../ai/steer/steering_acceleration.dart';
import '../ai/steer/steering_behavior.dart';
import '../anchor.dart';
import '../extensions/vector2.dart';
import 'position_component.dart';

class SteerableComponent extends PositionComponent implements Steerable {
  SteerableComponent({
    Vector2? velocity,
    double? angularVelocity,
    Vector2? position,
    double? angle,
    Vector2? size,
    Anchor? anchor,
  })  : _linearVelocity = velocity ?? Vector2.zero(),
        _angularVelocity = angularVelocity ?? 0,
        super(
          position: position,
          angle: angle,
          size: size,
          anchor: anchor ?? Anchor.center,
        );

  Vector2 _linearVelocity;
  double _maxLinearSpeed = 0;
  double _maxLinearAcceleration = 0;
  double _angularVelocity;
  double _maxAngularSpeed = 0;
  double _maxAngularAcceleration = 0;
  double _zeroLinearSpeedThreshold = 0.2;

  SteeringBehavior? _behavior;
  SteeringAcceleration steering = SteeringAcceleration();

  @mustCallSuper
  @override
  void update(double dt) {
    _behavior?.calculateSteering(dt, steering);
    position.x += _linearVelocity.x * dt;
    position.y += _linearVelocity.y * dt;
    angle += _angularVelocity * dt;
    _linearVelocity += steering.linearAcceleration * dt;
    _linearVelocity.clampMagnitude(_maxLinearSpeed);
    _angularVelocity = (_angularVelocity + steering.angularAcceleration * dt)
        .clamp(-_maxAngularAcceleration, _maxAngularAcceleration);
  }

  @override
  Vector2 get linearVelocity => _linearVelocity;

  @override
  double get angularSpeed => _angularVelocity;

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

  SteeringBehavior? get behavior => _behavior;
  set behavior(SteeringBehavior? value) {
    _behavior = value;
    _behavior?.owner = this;
  }
}
