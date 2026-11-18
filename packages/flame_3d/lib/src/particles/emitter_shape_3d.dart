import 'dart:math' as math;

import 'package:flame_3d/game.dart';

/// {@template emitter_shape_3d}
/// The volume or surface, relative to its emitter, in which particles spawn,
/// and the direction in which each of them starts moving.
///
/// Shapes are described around the emitter's local `+y` axis; the transform
/// of the particle system orients them. Subclass this for custom patterns.
/// {@endtemplate}
abstract class const EmitterShape3D() {
  /// Writes a spawn position, relative to the emitter, into [position] and the
  /// unit direction a particle spawned there starts moving in into
  /// [direction].
  ///
  /// It must not allocate: it runs for every particle spawned.
  void sample(math.Random random, Vector3 position, Vector3 direction);

  /// Writes a uniformly distributed random unit vector into [out].
  static void randomDirection(math.Random random, Vector3 out) {
    final z = random.nextDouble() * 2 - 1;
    final angle = random.nextDouble() * 2 * math.pi;
    final r = math.sqrt(math.max(0, 1 - z * z));
    out.setValues(r * math.cos(angle), r * math.sin(angle), z);
  }

  /// Writes into [out] a random unit vector within [angle] radians of the
  /// unit vector [axis], uniformly distributed over that cap of the sphere.
  ///
  /// [out] may be [axis].
  static void randomDirectionInCone(
    math.Random random,
    Vector3 axis,
    double angle,
    Vector3 out,
  ) {
    final ax = axis.x;
    final ay = axis.y;
    final az = axis.z;
    if (angle <= 0) {
      out.setValues(ax, ay, az);
      return;
    }
    final cosTheta = 1 - random.nextDouble() * (1 - math.cos(angle));
    final sinTheta = math.sqrt(math.max(0, 1 - cosTheta * cosTheta));
    final phi = random.nextDouble() * 2 * math.pi;
    // An orthonormal basis (u, v) perpendicular to the axis.
    double ux;
    double uy;
    double uz;
    if (ax.abs() < 0.9) {
      // u = normalize(axis x (1, 0, 0)).
      ux = 0;
      uy = az;
      uz = -ay;
    } else {
      // u = normalize(axis x (0, 1, 0)).
      ux = -az;
      uy = 0;
      uz = ax;
    }
    final length = math.sqrt(ux * ux + uy * uy + uz * uz);
    ux /= length;
    uy /= length;
    uz /= length;
    final vx = ay * uz - az * uy;
    final vy = az * ux - ax * uz;
    final vz = ax * uy - ay * ux;
    final cu = math.cos(phi) * sinTheta;
    final cv = math.sin(phi) * sinTheta;
    out.setValues(
      ax * cosTheta + ux * cu + vx * cv,
      ay * cosTheta + uy * cu + vy * cv,
      az * cosTheta + uz * cu + vz * cv,
    );
  }
}

/// Spawns every particle at the emitter's position, moving in a random
/// direction.
class const PointEmitterShape3D() extends EmitterShape3D {
  @override
  void sample(math.Random random, Vector3 position, Vector3 direction) {
    position.setZero();
    EmitterShape3D.randomDirection(random, direction);
  }
}

/// Spawns particles inside a sphere of [radius], or on its surface when
/// [surface] is `true`, moving away from its center.
///
/// With [hemisphere] only the upper half (`y >= 0`) is used.
class const SphereEmitterShape3D(
  /// The radius of the sphere.
  final double radius, {

  /// Whether particles spawn on the surface rather than inside.
  final bool surface = false,

  /// Whether only the half above the emitter (`y >= 0`) is used.
  final bool hemisphere = false,
}) extends EmitterShape3D {
  this : assert(radius >= 0, 'radius must not be negative');

  @override
  void sample(math.Random random, Vector3 position, Vector3 direction) {
    EmitterShape3D.randomDirection(random, direction);
    if (hemisphere && direction.y < 0) {
      direction.y = -direction.y;
    }
    final u = random.nextDouble();
    // Uniform over the volume: the cube root of a uniform value.
    final distance = surface || u <= 0
        ? (surface ? radius : 0.0)
        : radius * math.exp(math.log(u) / 3);
    position.setValues(
      direction.x * distance,
      direction.y * distance,
      direction.z * distance,
    );
  }
}

/// Spawns particles uniformly inside a box centered on the emitter, moving
/// along `+y`.
class const BoxEmitterShape3D(
  /// The size of the box along x.
  final double width,

  /// The size of the box along y.
  final double height,

  /// The size of the box along z.
  final double depth,
) extends EmitterShape3D {
  this
    : assert(
        width >= 0 && height >= 0 && depth >= 0,
        'the size must not be negative',
      );

  @override
  void sample(math.Random random, Vector3 position, Vector3 direction) {
    position.setValues(
      (random.nextDouble() - 0.5) * width,
      (random.nextDouble() - 0.5) * height,
      (random.nextDouble() - 0.5) * depth,
    );
    direction.setValues(0, 1, 0);
  }
}

/// Spawns particles on a disc of [radius] in the emitter's `xz` plane, or on
/// a ring when [innerRadius] is above zero (on a circle when it equals
/// [radius]).
///
/// Particles move along `+y`, or away from the center within the plane when
/// [radial] is `true` (a shock ring of dust, for instance).
class const DiscEmitterShape3D(
  /// The outer radius.
  final double radius, {

  /// The inner radius: particles spawn between it and [radius].
  final double innerRadius = 0,

  /// Whether particles move away from the center within the plane rather
  /// than along `+y`.
  final bool radial = false,
}) extends EmitterShape3D {
  this
    : assert(
        innerRadius >= 0 && innerRadius <= radius,
        'innerRadius must be between 0 and radius',
      );

  @override
  void sample(math.Random random, Vector3 position, Vector3 direction) {
    final angle = random.nextDouble() * 2 * math.pi;
    // Uniform over the area of the ring.
    final inner2 = innerRadius * innerRadius;
    final distance = math.sqrt(
      inner2 + random.nextDouble() * (radius * radius - inner2),
    );
    final c = math.cos(angle);
    final s = math.sin(angle);
    position.setValues(c * distance, 0, s * distance);
    if (radial) {
      direction.setValues(c, 0, s);
    } else {
      direction.setValues(0, 1, 0);
    }
  }
}

/// Spawns particles on the base of a cone opening along `+y` with the
/// half-angle [angle], moving out of the cone.
///
/// When [radius] is zero, particles spawn at the apex and move in a random
/// direction within the cone. Otherwise they spawn on the base disc of
/// [radius] and tilt away from the axis in proportion to their distance from
/// it, as if coming from a point below the base.
class const ConeEmitterShape3D({
  /// The half-angle of the cone, in radians.
  final double angle = math.pi / 8,

  /// The radius of the base.
  final double radius = 0,
}) extends EmitterShape3D {
  this
    : assert(
        angle >= 0 && angle <= math.pi,
        'angle must be between 0 and pi',
      ),
      assert(radius >= 0, 'radius must not be negative');

  @override
  void sample(math.Random random, Vector3 position, Vector3 direction) {
    if (radius <= 0) {
      position.setZero();
      direction.setValues(0, 1, 0);
      EmitterShape3D.randomDirectionInCone(random, direction, angle, direction);
      return;
    }
    final phi = random.nextDouble() * 2 * math.pi;
    final fraction = math.sqrt(random.nextDouble());
    final c = math.cos(phi);
    final s = math.sin(phi);
    position.setValues(c * fraction * radius, 0, s * fraction * radius);
    final tilt = angle * fraction;
    final sinTilt = math.sin(tilt);
    direction.setValues(c * sinTilt, math.cos(tilt), s * sinTilt);
  }
}
