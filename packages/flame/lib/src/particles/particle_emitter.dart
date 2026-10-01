import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/constants.dart';
import 'package:flame/src/particles/color_ramp.dart';
import 'package:flame/src/particles/emitter_shape.dart';
import 'package:flame/src/particles/particle_curve.dart';
import 'package:flame/src/particles/particle_range.dart';

/// A one-off release of [count] particles, [time] seconds after emission
/// starts.
class const EmitterBurst(
  /// Seconds after emission start at which the burst fires.
  final double time,

  /// The number of particles released by the burst.
  final int count,
) {
  /// Releases [count] particles [time] seconds after emission starts.
  this
    : assert(time >= 0, 'time must not be negative'),
      assert(count > 0, 'count must be positive');
}

/// A declarative description of how particles are spawned and how they
/// behave over their lifetime.
///
/// A [ParticleEmitter] is a reusable preset: the same instance can be shared
/// by any number of emitter components. All distances are in the emitter
/// component's local units, all angles in radians, and all times in seconds.
class ParticleEmitter({
  /// The maximum number of simultaneous particles. Storage for all of them
  /// is allocated up front; spawns beyond this limit are dropped until
  /// older particles die.
  final int maxParticles = 1024,

  /// Particles spawned per second, continuously. Zero means burst-only.
  final double rate = 0,

  /// One-off releases of particles at fixed times on the emission timeline.
  final List<EmitterBurst> bursts = const [],

  /// How long emission lasts. When null, a [rate]-based emitter emits
  /// forever, and a burst-only emitter finishes after its last burst.
  final double? duration,

  /// Whether the emission timeline restarts after [duration].
  final bool loop = false,

  /// The lifespan of each particle, in seconds.
  final ParticleRange lifespan = (1, 1),

  /// The area in which particles spawn, relative to the emitter's position.
  final EmitterShape shape = const PointEmitterShape(),

  /// The initial speed of each particle, in local units per second.
  final ParticleRange speed = (0, 0),

  /// The center of the emission direction, in radians. Zero points along
  /// the positive x-axis; `-tau / 4` points up.
  final double direction = 0,

  /// The angle, in radians, over which emission directions are spread,
  /// centered on [direction]. The default `tau` emits in all directions.
  final double spread = tau,
  Vector2? gravity,

  /// Velocity damping: each second, velocity is scaled by roughly
  /// `1 / (1 + drag)`. Zero means no damping.
  final double drag = 0,

  /// The rendered size (width and height) of each particle when it spawns,
  /// in local units.
  final ParticleRange size = (8, 8),

  /// The initial rotation of each particle, in radians. Ignored when
  /// [rotateToVelocity] is true.
  final ParticleRange rotation = (0, 0),

  /// The angular velocity of each particle, in radians per second. Ignored
  /// when [rotateToVelocity] is true.
  final ParticleRange spin = (0, 0),

  /// When true, each particle is rotated to point along its velocity,
  /// which suits directional particles such as sparks or arrows.
  final bool rotateToVelocity = false,

  /// How the particle's size scales over its lifetime, as a multiplier of
  /// its spawn [size]. When null the size stays constant.
  final ParticleCurve? scaleOverLife,

  /// How the particle's opacity changes over its lifetime, as a multiplier
  /// of the alpha from [colorOverLife] (or of full opacity when
  /// [colorOverLife] is null). Values are clamped to 0...1.
  final ParticleCurve? opacityOverLife,

  /// The particle's color over its lifetime. When null, particles are
  /// white; with texture renderers this leaves the texture untinted.
  final ColorRamp? colorOverLife,
}) {
  /// Creates an emitter preset.
  ///
  /// Emission is continuous through [rate] (particles per second) and/or
  /// discrete through [bursts]. An emitter with only bursts finishes after
  /// the last burst has fired; an emitter with a positive [rate] keeps
  /// emitting until [duration] has passed, or forever when [duration] is
  /// null. With [loop] enabled the emission timeline restarts after
  /// [duration], which must then be set.
  this
    : assert(maxParticles > 0, 'maxParticles must be positive'),
      assert(rate >= 0, 'rate must not be negative'),
      assert(spread >= 0, 'spread must not be negative'),
      assert(drag >= 0, 'drag must not be negative'),
      assert(duration == null || duration > 0, 'duration must be positive'),
      assert(
        !loop || duration != null,
        'loop requires duration to be set',
      );

  /// A constant acceleration applied to every particle, in local units per
  /// second squared.
  final Vector2 gravity = gravity ?? Vector2.zero();

  /// The time at which emission naturally ends: [duration] when set,
  /// infinity for an endless [rate]-based emitter, and the time of the last
  /// burst for a burst-only emitter.
  double get emissionEndTime {
    final duration = this.duration;
    if (duration != null) {
      return duration;
    }
    if (rate > 0) {
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
