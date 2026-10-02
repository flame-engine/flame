import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flutter/animation.dart';

/// A controller that grows non-linearly from 1 to 0 following the provided
/// [curve]. The [duration] cannot be 0.
class ReverseCurvedEffectController(super.duration, final Curve _curve)
    extends DurationEffectController {
  this : assert(duration > 0, 'Duration must be positive: $duration');

  Curve get curve => _curve;
  @override
  double get progress => _curve.transform(1 - timer / duration);
}
