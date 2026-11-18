import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/particles.dart';

/// {@template particle_emitter_3d}
/// Describes how particles enter a [ParticleSystem3D]: when (a continuous
/// [rate], [bursts] on a timeline, or a rate per distance traveled), where
/// (the [shape], moved by [offset]) and with which initial values (lifespan,
/// speed, size, rotation, spin, color...).
///
/// How particles behave afterwards (forces, collisions, curves over their
/// life) is up to the system they are spawned into. An emitter is immutable
/// and can be shared by any number of systems.
///
/// Distances are in the units of the system's local space, angles in
/// radians, times in seconds. Values that vary from particle to particle are
/// [ParticleRange]s, `(min, max)` records sampled uniformly.
/// {@endtemplate}
class ParticleEmitter3D({
  /// Particles spawned per second, continuously.
  final double rate = 0,

  /// Particles spawned per unit of distance the system's origin travels,
  /// spread along the way: a trail behind a moving system.
  final double ratePerDistance = 0,

  /// One-off releases of particles at fixed times on the emission timeline.
  final List<EmitterBurst> bursts = const [],

  /// How long emission lasts. When `null`, an emitter with a [rate] emits
  /// forever and one with only [bursts] finishes after its last burst.
  final double? duration,

  /// Whether the emission timeline restarts after [duration], which must then
  /// be set.
  final bool loop = false,

  /// Where particles spawn, relative to the emitter, and the direction they
  /// start moving in.
  final EmitterShape3D shape = const PointEmitterShape3D(),
  Vector3? offset,

  /// The lifespan of each particle.
  final ParticleRange lifespan = (1, 1),

  /// The initial speed of each particle along the direction given by the
  /// [shape].
  final ParticleRange speed = (0, 0),

  /// The half-angle, in radians, of a cone around the shape's direction
  /// within which the actual direction is chosen at random.
  final double spread = 0,
  Vector3? velocity,

  /// The fraction of the velocity of the system's origin that particles
  /// inherit when they spawn.
  final double inheritVelocity = 0,

  /// The width of each particle when it spawns (the scale of a mesh
  /// particle).
  final ParticleRange size = (0.1, 0.1),

  /// The height of each billboard as a multiple of its width.
  final ParticleRange aspect = (1, 1),

  /// The initial rotation of each particle: in the billboard's plane, or
  /// about the spin axis of a mesh particle.
  final ParticleRange rotation = (0, 0),

  /// The angular velocity of each particle, in radians per second.
  final ParticleRange spin = (0, 0),

  /// A multiplier of the system's gravity for each particle, so that light
  /// and heavy particles can share a system.
  final ParticleRange gravityScale = (1, 1),

  /// The initial colors: each particle takes one of them at random.
  final List<Color> colors = const [Color(0xFFFFFFFF)],
}) {
  /// {@macro particle_emitter_3d}
  this
    : assert(rate >= 0, 'rate must not be negative'),
      assert(ratePerDistance >= 0, 'ratePerDistance must not be negative'),
      assert(spread >= 0, 'spread must not be negative'),
      assert(duration == null || duration > 0, 'duration must be positive'),
      assert(!loop || duration != null, 'loop requires duration to be set'),
      assert(colors.isNotEmpty, 'colors must not be empty');

  /// Where the emitter is relative to the system's origin.
  final Vector3 offset = offset?.clone() ?? Vector3.zero();

  /// A velocity added to every particle when it spawns, in the system's
  /// simulation space (for example the fall of rain).
  final Vector3 velocity = velocity?.clone() ?? Vector3.zero();

  /// The time at which emission naturally ends: [duration] when set,
  /// infinity for an endless [rate] or [ratePerDistance] emitter, and the time
  /// of the last burst for a burst-only emitter.
  double get emissionEndTime {
    final duration = this.duration;
    if (duration != null) {
      return duration;
    }
    if (rate > 0 || ratePerDistance > 0) {
      return double.infinity;
    }
    var end = 0.0;
    for (final burst in bursts) {
      if (burst.time > end) {
        end = burst.time;
      }
    }
    return end;
  }
}
