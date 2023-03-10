import 'package:fast_noise/fast_noise.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curve, Curves;

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
class PerlinNoiseEffectController extends DurationEffectController {
  PerlinNoiseEffectController({
    required double duration,
    int octaves = 3,
    double frequency = 0.05,
    this.taperingCurve = Curves.easeInOutCubic,
    int seed = 1337,
  })  : assert(duration > 0, 'duration must be positive'),
        assert(frequency > 0, 'frequency parameter must be positive'),
        noise = PerlinNoise(seed: seed, octaves: octaves, frequency: frequency),
        super(duration);

  final Curve taperingCurve;
  final PerlinNoise noise;

  @override
  double get progress {
    final x = timer / duration;
    final amplitude = taperingCurve.transform(1 - x);
    return noise.getPerlin2(x, 1) * amplitude;
  }
}
