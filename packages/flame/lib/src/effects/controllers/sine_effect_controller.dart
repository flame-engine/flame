import 'dart:math' as math;
import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flame/src/effects/controllers/infinite_effect_controller.dart';
import 'package:flame/src/effects/controllers/repeated_effect_controller.dart';

/// This effect controller follows a sine wave.
///
/// Use this controller to create effects that exhibit natural-looking harmonic
/// motion.
///
/// Combine with [RepeatedEffectController] or [InfiniteEffectController] in
/// order to create longer waves.
class SineEffectController extends DurationEffectController {
  SineEffectController({required double period})
      : assert(period > 0, 'Period must be positive: $period'),
        super(period);

  @override
  double get progress {
    const tau = math.pi * 2;
    return math.sin(tau * timer / duration);
  }
}
