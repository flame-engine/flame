import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../particle_component.dart';

/// A single [Particle] which manages multiple children
/// by proxying all lifecycle hooks.
class ComposedParticle extends Particle {
  final List<Particle> children;

  ComposedParticle({
    @required this.children,
    double lifespan,
    Duration duration,
  }) : super(
          lifespan: lifespan,
          duration: duration,
        );

  @override
  void setLifespan(double lifespan) {
    super.setLifespan(lifespan);

    for (var child in children) {
      child.setLifespan(lifespan);
    }
  }

  @override
  void render(Canvas c) {
    for (var child in children) {
      child.render(c);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var child in children) {
      child.update(dt);
    }
  }
}
