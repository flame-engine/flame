import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flutter/animation.dart';

/// A controller that grows non-linearly from 0 to 1 following the provided
/// [curve]. The [duration] cannot be 0.
class CurvedEffectController extends DurationEffectController {
  CurvedEffectController(super.duration, Curve curve)
      : assert(duration > 0, 'Duration must be positive: $duration'),
        _curve = curve;

  Curve get curve => _curve;
  final Curve _curve;

  @override
  double get progress => _curve.transform(timer / duration);
}
