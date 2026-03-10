import 'package:flame/src/effects/hue_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// An effect that changes the hue of a component to a specified angle.
class HueToEffect extends HueEffect {
  HueToEffect(
    double angle,
    super.controller, {
    HueProvider? target,
    super.onComplete,
    super.key,
  }) : _destinationAngle = angle,
       _angle = 0 {
    this.target = target;
  }

  final double _destinationAngle;
  double _angle;

  @override
  void onStart() {
    _angle = _destinationAngle - target.hue;
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.hue += _angle * dProgress;
  }
}
