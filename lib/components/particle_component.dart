import 'dart:ui';

import 'package:flame/components/particles/composed_particle.dart';
import 'package:flutter/foundation.dart';

import '../time.dart';
import 'component.dart';

/// A function which returns [Particle] when called
typedef ParticleGenerator = Particle Function(int);

/// Base class implementing common behavior for all the particles.
///
/// Intention is to follow same "Extreme Composability" style
/// as across the whole Flutter framework, so each type of particle implements
/// some particular behavior which then could be nested and combined together
/// to create specifically required experience.
abstract class Particle extends Component {
  /// Generates given amount of particles,
  /// combining them into one [ComposedParticle]
  /// Useful for procedural particle generation.
  static Particle generate({
    int count = 10,
    @required ParticleGenerator generator,
    double lifespan,
    Duration duration,
  }) {
    return ComposedParticle(
      lifespan: lifespan,
      duration: duration,
      children: List<Particle>.generate(count, generator),
    );
  }

  Timer _timer;
  bool _shouldBeDestroyed = false;

  Particle({
    /// Particle lifespan in [Timer] format,
    /// double in seconds with microsecond precision
    double lifespan,

    /// Another way to set lifespan, using Flutter
    /// [Duration] class
    Duration duration,
  }) {
    /// Either [double] lifespan or [Duration] duration,
    /// defaulting to 500 milliseconds of life (or .5, in [Timer] double)
    lifespan = lifespan ??
        (duration ?? const Duration(milliseconds: 500)).inMicroseconds /
            Duration.microsecondsPerSecond;

    setLifespan(lifespan);
  }

  @override
  bool destroy() => _shouldBeDestroyed;
  double get progress => _timer.progress;

  @override
  void render(Canvas canvas) {
    // Do nothing by default
  }

  @override
  void update(double dt) {
    _timer.update(dt);

    if (_timer.progress >= 1) {
      _shouldBeDestroyed = true;
    }
  }

  void setLifespan(double lifespan) {
    _timer?.stop();
    _timer = Timer(lifespan);
    _timer.start();
  }
}
