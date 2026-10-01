import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/constants.dart';

/// The area, relative to the emitter's position, in which new particles
/// spawn.
///
/// Subclass this to spawn particles in custom patterns.
abstract class const EmitterShape() {
  /// Writes a spawn offset, relative to the emitter, into [out].
  void samplePosition(Random random, Vector2 out);
}

/// Spawns every particle exactly at the emitter's position.
class const PointEmitterShape() extends EmitterShape {
  @override
  void samplePosition(Random random, Vector2 out) => out.setZero();
}

/// Spawns particles uniformly inside a circle, or on its edge when
/// [edgeOnly] is true.
class const CircleEmitterShape(
  /// The radius of the spawn circle, in local units.
  final double radius, {

  /// When true, particles spawn on the circle's edge instead of inside it.
  final bool edgeOnly = false,
}) extends EmitterShape {
  @override
  void samplePosition(Random random, Vector2 out) {
    final angle = random.nextDouble() * tau;
    final distance = edgeOnly ? radius : radius * sqrt(random.nextDouble());
    out.setValues(cos(angle) * distance, sin(angle) * distance);
  }
}

/// Spawns particles uniformly inside a rectangle centered on the emitter.
class const RectangleEmitterShape(
  /// The width of the spawn rectangle, in local units.
  final double width,

  /// The height of the spawn rectangle, in local units.
  final double height,
) extends EmitterShape {
  @override
  void samplePosition(Random random, Vector2 out) {
    out.setValues(
      (random.nextDouble() - 0.5) * width,
      (random.nextDouble() - 0.5) * height,
    );
  }
}
