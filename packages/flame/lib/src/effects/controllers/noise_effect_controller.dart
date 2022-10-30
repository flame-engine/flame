import 'dart:math';

import 'package:flame/src/effects/controllers/duration_effect_controller.dart';
import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:vector_math/vector_math_64.dart';

/// Effect controller that oscillates around 0 following a noise curve.
///
/// The [frequency] parameter controls smoothness/jerkiness of the oscillations.
/// It is roughly proportional to the total number of swings for the duration
/// of the effect.
///
/// The [taperingCurve] describes how the effect fades out over time. The
/// curve that you supply will be flipped along the X axis, so that the effect
/// starts at full force, and gradually reduces to zero towards the end.
///
/// This effect controller can be used to implement various shake effects. For
/// example, putting into a `MoveEffect.by` will create a shake motion, where
/// the magnitude and the direction of shaking is controlled by the effect's
/// `offset`.
class NoiseEffectController extends DurationEffectController {
  NoiseEffectController({
    required double duration,
    required this.frequency,
    this.taperingCurve = Curves.easeInOutCubic,
    Random? random,
  })  : assert(duration > 0, 'duration must be positive'),
        assert(frequency > 0, 'frequency parameter must be positive'),
        noise = SimplexNoise(random),
        super(duration);

  final double frequency;
  final Curve taperingCurve;
  final SimplexNoise noise;

  @override
  double get progress {
    final x = timer / duration;
    final amplitude = taperingCurve.transform(1 - x);
    return noise.noise2D(x * frequency, 0) * amplitude;
  }
}
