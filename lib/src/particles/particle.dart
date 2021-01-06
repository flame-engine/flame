import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/component.dart';
import '../components/particle_component.dart';
import 'accelerated_particle.dart';
import 'composed_particle.dart';
import 'moving_particle.dart';
import 'rotating_particle.dart';
import 'scaled_particle.dart';
import 'translated_particle.dart';
import '../timer.dart';

/// A function which returns [Particle] when called
typedef ParticleGenerator = Particle Function(int);

/// Base class implementing common behavior for all the particles.
///
/// Intention is to follow same "Extreme Composability" style
/// as across the whole Flutter framework, so each type of particle implements
/// some particular behavior which then could be nested and combined together
/// to create specifically required experience.
abstract class Particle {
  /// Generates given amount of particles,
  /// combining them into one [ComposedParticle]
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

  /// Internal timer defining how long
  /// this [Particle] will live. [Particle] will
  /// be marked for removal when this timer is over.
  Timer? _timer;

  /// Stores desired lifespan of the
  /// particle in seconds.
  late double _lifespan;

  /// Will be set to true by update hook
  /// when this [Particle] reaches end of its lifespan
  bool _shouldBeRemoved = false;

  Particle({
    /// Particle lifespan in [Timer] format,
    /// double in seconds with microsecond precision
    double? lifespan,
  }) {
    setLifespan(lifespan ?? .5);
  }

  /// This method will return true as
  /// soon as particle reaches an end of its
  /// lifespan, which means it's ready to be
  /// removed by a wrapping container.
  /// Follows same style as [Component].
  bool shouldRemove() => _shouldBeRemoved;

  /// Getter which should be used by subclasses
  /// to get overall progress. Also allows to substitute
  /// progres with other values, for example adding easing as in [CurvedParticle].
  double get progress => _timer?.progress ?? 0.0;

  /// Should render this [Particle] to given [Canvas].
  /// Default behavior is empty, so that it's not
  /// required to override this in [Particle] which
  /// render nothing and serve as behavior containers.
  void render(Canvas canvas) {
    // Do nothing by default
  }

  /// Updates internal [Timer] of this [Particle]
  /// which defines its position on the lifespan.
  /// Marks [Particle] for removal when it is over.
  void update(double dt) {
    _timer?.update(dt);
  }

  /// A control method allowing a parent of this [Particle]
  /// to pass down it's lifespan. Allows to only specify desired lifespan
  /// once, at the very top of the [Particle] tree which
  /// then will be propagated down using this method.
  /// See [SingleChildParticle] or [ComposedParticle] for details.
  void setLifespan(double lifespan) {
    _lifespan = lifespan;
    _timer?.stop();
    final void Function() removeCallback = () => _shouldBeRemoved = true;
    _timer = Timer(lifespan, callback: removeCallback);
    _timer!.start();
  }

  /// Wraps this particle with [TranslatedParticle]
  /// statically repositioning it for the time
  /// of the lifespan.
  Particle translated(Offset offset) {
    return TranslatedParticle(
      offset: offset,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Wraps this particle with [MovingParticle]
  /// allowing it to move from one [Offset]
  /// on the canvas to another one.
  Particle moving({
    Offset from = Offset.zero,
    required Offset to,
    Curve curve = Curves.linear,
  }) {
    return MovingParticle(
      from: from,
      to: to,
      curve: curve,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Wraps this particle with [AcceleratedParticle]
  /// allowing to specify desired position speed and acceleration
  /// and leave the basic physics do the rest.
  Particle accelerated({
    Offset acceleration = Offset.zero,
    Offset position = Offset.zero,
    Offset speed = Offset.zero,
  }) {
    return AcceleratedParticle(
      position: position,
      speed: speed,
      acceleration: acceleration,
      child: this,
      lifespan: _lifespan,
    );
  }

  /// Rotates this particle to a fixed angle
  /// in radians with [RotatingParticle]
  Particle rotated([double angle = 0]) {
    return RotatingParticle(
        child: this, lifespan: _lifespan, from: angle, to: angle);
  }

  /// Rotates this particle from given angle
  /// to another one in radians with [RotatingParticle]
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

  /// Wraps this particle with [ScaledParticle]
  /// allowing to change size of it and/or its children
  Particle scaled(double scale) {
    return ScaledParticle(scale: scale, child: this, lifespan: _lifespan);
  }

  /// Wraps this particle with [ParticleComponent]
  /// to be used within the [BaseGame] component system.
  Component asComponent() {
    return ParticleComponent(particle: this);
  }
}
