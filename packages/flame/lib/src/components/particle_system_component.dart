import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// {@template particle_system_component}
/// A [PositionComponent] that renders a [Particle] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
/// {endtempalte}
class ParticleSystemComponent extends PositionComponent {
  Particle? particle;

  /// {@macro particle_system_component}
  ParticleSystemComponent({
    this.particle,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  });

  /// Returns progress of the child [Particle].
  ///
  /// Could be used by external code if needed.
  double get progress => particle?.progress ?? 0;

  /// Passes rendering chain down to the inset
  /// [Particle] within this [Component].
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    particle?.render(canvas);
  }

  /// Passes update chain to child [Particle].
  @override
  void update(double dt) {
    particle?.update(dt);
    if (particle?.shouldRemove ?? false) {
      removeFromParent();
    }
  }
}
