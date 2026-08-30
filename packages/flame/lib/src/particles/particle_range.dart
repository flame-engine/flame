import 'dart:math';

/// An inclusive range of doubles from which per-particle values are sampled.
///
/// Emitter properties that vary from particle to particle (lifespan, speed,
/// size, spin, etc.) are expressed as a `(min, max)` record. Use the same
/// value twice to get a constant, for example `(5, 5)`.
typedef ParticleRange = (double min, double max);

/// Sampling helper for [ParticleRange].
extension ParticleRangeExtension on ParticleRange {
  /// Returns a value uniformly sampled between `min` and `max`.
  double sample(Random random) => $1 + ($2 - $1) * random.nextDouble();
}
