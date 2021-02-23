import 'dart:ui';

import '../../particles/particle.dart';

/// Implements basic behavior for nesting [Particle] instances
/// into each other.
///
/// ```dart
/// class BehaviorParticle extends Particle with SingleChildParticle {
///   Particle child;
///
///   BehaviorParticle({
///     @required this.child
///   });
///
///   @override
///   update(double dt) {
///     // Will ensure that child [Particle] is properly updated
///     super.update(dt);
///
///     // ... Custom behavior
///   }
/// }
/// ```
mixin SingleChildParticle on Particle {
  Particle child;

  @override
  void setLifespan(double lifespan) {
    assert(child != null);

    super.setLifespan(lifespan);
    child.setLifespan(lifespan);
  }

  @override
  void render(Canvas c) {
    assert(child != null);

    child.render(c);
  }

  @override
  void update(double dt) {
    assert(child != null);

    super.update(dt);
    child.update(dt);
  }
}
