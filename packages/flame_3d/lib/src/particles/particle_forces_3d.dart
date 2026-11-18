import 'dart:math' as math;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/particles.dart';

/// {@template particle_turbulence_3d}
/// A swirling, divergence-free flow (curl noise) that pushes the particles of
/// a [ParticleSystem3D] around, for smoke, dust and embers.
///
/// The flow is the curl of a smooth vector field made of a few sine waves
/// whose phases depend on the system's seed; it changes over time at
/// [speed]. Being divergence free, it swirls particles about without
/// gathering them in clumps.
/// {@endtemplate}
class const ParticleTurbulence3D({
  /// The acceleration the flow can reach, in units per second squared.
  final double strength = 1,

  /// The number of swirls per unit of distance (roughly): higher values give
  /// smaller swirls.
  final double frequency = 1,

  /// How fast the flow changes, in radians of phase per second.
  final double speed = 1,
}) {
  /// {@macro particle_turbulence_3d}
  this : assert(frequency > 0, 'frequency must be positive');
}

/// {@template particle_ground_3d}
/// A ground plane the particles of a [ParticleSystem3D] collide with: they
/// bounce off it, slide on it and come to rest.
///
/// The plane is the set of points `p` with `dot(p, normal) == height`, in
/// the system's simulation space. Each bounce faster than [restSpeed] calls
/// the system's [ParticleSystem3D.onGroundHit] (after the simulation step, so
/// the callback may spawn particles).
/// {@endtemplate}
class ParticleGround3D({
  /// The distance of the plane from the origin, along [normal].
  final double height = 0,
  Vector3? normal,

  /// The fraction of the speed into the ground that a bounce sends back.
  final double restitution = 0.4,

  /// The fraction of the speed along the ground that a bounce keeps.
  final double friction = 0.8,

  /// How fast particles resting on the ground stop sliding (and spinning),
  /// per second.
  final double slideDrag = 4,

  /// The speed into the ground below which a particle comes to rest instead
  /// of bouncing.
  final double restSpeed = 0.25,

  /// The fraction of a particle's current size by which it stays above the
  /// plane: `0.5` keeps a billboard's or a unit mesh's edge on the ground.
  final double sizeOffset = 0,

  /// Whether particles die when they hit the ground (rain, for instance),
  /// after the hit is reported.
  final bool killOnHit = false,

  /// Whether particles at rest turn back to a rotation of zero (the mesh's
  /// own orientation: a coin modelled lying flat ends up lying flat).
  final bool settleRotation = false,
}) {
  /// {@macro particle_ground_3d}
  this
    : assert(
        restitution >= 0 && restitution <= 1,
        'restitution must be between 0 and 1',
      ),
      assert(
        friction >= 0 && friction <= 1,
        'friction must be between 0 and 1',
      ),
      assert(slideDrag >= 0, 'slideDrag must not be negative'),
      assert(restSpeed >= 0, 'restSpeed must not be negative');

  /// The unit normal of the plane, pointing to the side particles live on;
  /// `+y` by default.
  final Vector3 normal = _unit(normal);

  static Vector3 _unit(Vector3? normal) {
    if (normal == null || normal.length2 == 0) {
      return Vector3(0, 1, 0);
    }
    return normal.normalized();
  }
}

/// {@template particle_attractor_3d}
/// Pulls the particles of a [ParticleSystem3D] towards [target], for coins
/// flying into a purse or sparks drawn into a portal.
///
/// Particles accelerate towards the target at [strength]; once within
/// [arrivalRadius] they arrive: they are removed when [consumeOnArrival] is
/// `true`, and [onArrived] is called once per simulation step with the
/// number of particles that arrived during it.
///
/// The target is in the system's simulation space; move it with
/// `target.setValues(...)` at any time.
/// {@endtemplate}
class ParticleAttractor3D({
  required Vector3 target,

  /// The acceleration towards the target, in units per second squared.
  var double strength = 10,

  /// The distance from the target at which particles arrive.
  var double arrivalRadius = 0.1,

  /// Whether arriving particles are removed.
  var bool consumeOnArrival = true,

  /// Called after a simulation step with the number of particles that
  /// arrived during it.
  var void Function(int count)? onArrived,
}) {
  /// {@macro particle_attractor_3d}
  this : assert(arrivalRadius >= 0, 'arrivalRadius must not be negative');

  /// The point particles are pulled to.
  final Vector3 target = target.clone();
}

/// How the frame of a flipbook ([ParticleMaterial.frameCount] frames) is
/// chosen for each particle, see [ParticleFlipbook3D].
enum ParticleFrameMode() {
  /// Plays the frames over the particle's life, [ParticleFlipbook3D.cycles]
  /// times.
  overLife,

  /// Plays the frames at [ParticleFlipbook3D.fps] frames per second.
  fps,

  /// Keeps one random frame per particle (variants of a sprite).
  random,
}

/// {@template particle_flipbook_3d}
/// How a [ParticleSystem3D] picks the flipbook frames of its particles from
/// the frames of its [ParticleMaterial].
/// {@endtemplate}
class const ParticleFlipbook3D({
  /// How the frame is chosen.
  final ParticleFrameMode mode = ParticleFrameMode.overLife,

  /// The frame rate of [ParticleFrameMode.fps].
  final double fps = 12,

  /// How many times the frames play over a particle's life in
  /// [ParticleFrameMode.overLife].
  final double cycles = 1,

  /// Whether each particle starts at a random frame.
  final bool randomStart = false,
}) {
  /// {@macro particle_flipbook_3d}
  this
    : assert(fps >= 0, 'fps must not be negative'),
      assert(cycles > 0, 'cycles must be positive');
}

/// Evaluates the curl noise of [ParticleTurbulence3D] at a point and time.
///
/// The flow is the curl of the field `(A(y, z), B(z, x), C(x, y))`, each
/// component a product of two sine waves; the curl of any smooth field is
/// divergence free.
class CurlNoise3D(int seed) {
  // Phases derived from the seed, one per wave.
  final List<double> _phase = _phases(seed);

  /// The flow at ([x], [y], [z]) and [time], scaled to an acceleration of at
  /// most about [strength] for the given [frequency], written into [out].
  void sample(
    double x,
    double y,
    double z,
    double time,
    double frequency,
    double strength,
    Vector3 out,
  ) {
    final p = _phase;
    final f = frequency;
    // A = sin(f y + t + p0) cos(1.31 f z + p1)
    final ay = f * y + time + p[0];
    final az = 1.31 * f * z + p[1];
    // B = sin(1.13 f z + 0.8 t + p2) cos(0.87 f x + p3)
    final bz = 1.13 * f * z + 0.8 * time + p[2];
    final bx = 0.87 * f * x + p[3];
    // C = sin(1.21 f x + 1.1 t + p4) cos(1.07 f y + p5)
    final cx = 1.21 * f * x + 1.1 * time + p[4];
    final cy = 1.07 * f * y + p[5];

    final sinAy = math.sin(ay);
    final cosAy = math.cos(ay);
    final sinAz = math.sin(az);
    final cosAz = math.cos(az);
    final sinBz = math.sin(bz);
    final cosBz = math.cos(bz);
    final sinBx = math.sin(bx);
    final cosBx = math.cos(bx);
    final sinCx = math.sin(cx);
    final cosCx = math.cos(cx);
    final sinCy = math.sin(cy);
    final cosCy = math.cos(cy);

    // curl = (dC/dy - dB/dz, dA/dz - dC/dx, dB/dx - dA/dy), divided by f so
    // that the strength does not depend on the frequency.
    final scale = strength * 0.5;
    out.setValues(
      (-1.07 * sinCx * sinCy - 1.13 * cosBz * cosBx) * scale,
      (-1.31 * sinAy * sinAz - 1.21 * cosCx * cosCy) * scale,
      (-0.87 * sinBz * sinBx - cosAy * cosAz) * scale,
    );
  }

  static List<double> _phases(int seed) {
    final random = math.Random(seed);
    return List<double>.generate(
      6,
      (_) => random.nextDouble() * 2 * math.pi,
      growable: false,
    );
  }
}
