import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';

import '../../extensions.dart';
import '../timer.dart';
import 'accelerated_particle.dart';
import 'composed_particle.dart';
import 'moving_particle.dart';
import 'rotating_particle.dart';
import 'scaled_particle.dart';
import 'translated_particle.dart';

/// A function which returns a [Particle] when called.
typedef ParticleGenerator = Particle Function(int);

/// Base class implementing common behavior for all the particles.
///
/// Intention is to follow the same "Extreme Composability" style as seen across
/// the whole Flutter framework. Each type of particle implements some
/// particular behavior which then could be nested and combined to create
/// the experience you are looking for.
abstract class Particle {
  /// Generates a given amount of particles and then combining them into one
  /// single [ComposedParticle].
  ///
  /// Useful for procedural particle generation.
  static Particle generate({
    int count = 10,
    required ParticleGenerator generator,
    double? lifespan,
  }) {
    return ComposedParticle(
      lifespan: lifespan,
      children: List<Particle>.generate(count, generator),
    );
  }

  /// Internal timer defining how long this [Particle] will live.
  ///
  /// [Particle] will be marked for removal when this timer is over.
  Timer? _timer;

  /// Stores desired lifespan of the particle in seconds.
  late double _lifespan;

  /// Will be set to true by [update] when this [Particle] reaches the end of
  /// its lifespan.
  bool _shouldBeRemoved = false;

  /// Construct a new [Particle].
  ///
  /// The [lifespan] is how long this [Particle] will live in seconds, with
  /// microsceond precision.
  Particle({
    double? lifespan,
  }) {
    setLifespan(lifespan ?? .5);
  }

  /// This method will return true as soon as the particle reaches the end of
  /// its lifespan.
  ///
  /// It will then be ready to be removed by a wrapping container.
  bool get shouldRemove => _shouldBeRemoved;

  /// Getter which should be used by subclasses to get overall progress.
  ///
  /// Also allows to substitute progress with other values, for example adding
  /// easing as in CurvedParticle.
  double get progress => _timer?.progress ?? 0.0;

  /// Should render this [Particle] to given [Canvas].
  ///
  /// Default behavior is empty, so that it's not required to override this in
  /// a [Particle] that renders nothing and serve as a behavior container.
  void render(Canvas canvas) {}

  /// Updates the [_timer] of this [Particle].
  void update(double dt) {
    _timer?.update(dt);
  }

  /// A control method allowing a parent of this [Particle] to pass down it's
  /// lifespan.
  ///
  /// Allows to only specify desired lifespan once, at the very top of the
  /// [Particle] tree which then will be propagated down using this method.
  ///
  /// See `SingleChildParticle` or [ComposedParticle] for details.
  void setLifespan(double lifespan) {
    // TODO: Maybe make it into a setter/getter?
    _lifespan = lifespan;
    _timer?.stop();
    _timer = Timer(lifespan, callback: () => _shouldBeRemoved = true)..start();
  }

  /// Wraps this particle with a [TranslatedParticle].
  ///
  /// Statically repositioning it for the time of the lifespan.
  Particle translated(Vector2 offset) {
    return TranslatedParticle(
      offset: offset,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Wraps this particle with a [MovingParticle].
  ///
  /// Allowing it to move from one [Vector2] to another one.
  Particle moving({
    Vector2? from,
    required Vector2 to,
    Curve curve = Curves.linear,
  }) {
    return MovingParticle(
      from: from ?? Vector2.zero(),
      to: to,
      curve: curve,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Wraps this particle with a [AcceleratedParticle].
  ///
  /// Allowing to specify desired position speed and acceleration and leave
  /// the basic physics do the rest.
  Particle accelerated({
    required Vector2 acceleration,
    Vector2? position,
    Vector2? speed,
  }) {
    return AcceleratedParticle(
      position: position ?? Vector2.zero(),
      speed: speed ?? Vector2.zero(),
      acceleration: acceleration,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Rotates this particle to a fixed angle in radians using [RotatingParticle].
  Particle rotated(double angle) {
    return RotatingParticle(
      child: this,
      lifespan: _lifespan,
      from: angle,
      to: angle,
    );
  }

  /// Rotates this particle from a given angle to another one in radians
  /// using [RotatingParticle].
  Particle rotating({
    double from = 0,
    double to = pi,
  }) {
    return RotatingParticle(
      child: this,
      lifespan: _lifespan,
      from: from,
      to: to,
    );
  }

  /// Wraps this particle with a [ScaledParticle].
  ///
  /// Allows for chainging the size of this particle and/or its children.
  Particle scaled(double scale) {
    return ScaledParticle(scale: scale, child: this, lifespan: _lifespan);
  }
}
