import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/constants.dart';

/// The area, relative to the emitter's position, in which new particles
/// spawn.
///
/// Subclass this to spawn particles in custom patterns.
abstract class EmitterShape {
  /// Allows subclasses to have const constructors.
  const EmitterShape();

  /// Writes a spawn offset, relative to the emitter, into [out].
  void samplePosition(Random random, Vector2 out);
}

/// Spawns every particle exactly at the emitter's position.
class PointEmitterShape extends EmitterShape {
  /// Spawns every particle exactly at the emitter's position.
  const PointEmitterShape();

  @override
  void samplePosition(Random random, Vector2 out) => out.setZero();
}

/// Spawns particles uniformly inside a circle, or on its edge when
/// [edgeOnly] is true.
class CircleEmitterShape extends EmitterShape {
  /// Spawns particles inside (or on the edge of) a circle with the given
  /// [radius].
  const CircleEmitterShape(this.radius, {this.edgeOnly = false});

  /// The radius of the spawn circle, in local units.
  final double radius;

  /// When true, particles spawn on the circle's edge instead of inside it.
  final bool edgeOnly;

  @override
  void samplePosition(Random random, Vector2 out) {
    final angle = random.nextDouble() * tau;
    final distance = edgeOnly ? radius : radius * sqrt(random.nextDouble());
    out.setValues(cos(angle) * distance, sin(angle) * distance);
  }
}

/// Spawns particles uniformly inside a rectangle centered on the emitter.
class RectangleEmitterShape extends EmitterShape {
  /// Spawns particles inside a centered rectangle of [width] by [height].
  const RectangleEmitterShape(this.width, this.height);

  /// The width of the spawn rectangle, in local units.
  final double width;

  /// The height of the spawn rectangle, in local units.
  final double height;

  @override
  void samplePosition(Random random, Vector2 out) {
    out.setValues(
      (random.nextDouble() - 0.5) * width,
      (random.nextDouble() - 0.5) * height,
    );
  }
}
