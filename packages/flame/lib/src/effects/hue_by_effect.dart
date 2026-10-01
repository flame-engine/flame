import 'package:flame/src/effects/hue_effect.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// An effect that changes the hue of a component by a specified angle.
class HueByEffect(
  final double _angle,
  super.controller, {
  HueProvider? target,
  super.onComplete,
  super.key,
}) extends HueEffect {
  this {
    this.target = target;
  }

  @override
  void apply(double progress) {
    final dProgress = progress - previousProgress;
    target.hue += _angle * dProgress;
  }
}
