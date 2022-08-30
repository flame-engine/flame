import 'dart:ui';

import 'package:flame/src/particles/particle.dart';

/// A single [Particle] which manages multiple children
/// by proxying all lifecycle hooks.
class ComposedParticle extends Particle {
  final List<Particle> children;
  final bool applyLifespanToChildren;

  ComposedParticle({
    required this.children,
    super.lifespan,
    this.applyLifespanToChildren = true,
  });

  @override
  void setLifespan(double lifespan) {
    super.setLifespan(lifespan);

    if (applyLifespanToChildren) {
      for (final child in children) {
        child.setLifespan(lifespan);
      }
    }
  }

  @override
  void render(Canvas c) {
    for (final child in children) {
      if (!child.shouldRemove) {
        child.render(c);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final child in children) {
      if (!child.shouldRemove) {
        child.update(dt);
      }
    }
  }
}
