import 'package:fast_noise/fast_noise.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curve, Curves;

/// Effect controller that oscillates around following a noise curve.
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
  final Curve taperingCurve;
  final Noise2 noise;

  NoiseEffectController({
    required double duration,
    this.taperingCurve = Curves.easeInOutCubic,
    Noise2? noise,
  }) : noise = noise ?? PerlinNoise(),
       super(duration);

  @override
  double get progress {
    final x = timer / duration;
    final amplitude = taperingCurve.transform(1 - x);
    return noise.getNoise2(x, 1) * amplitude;
  }
}
