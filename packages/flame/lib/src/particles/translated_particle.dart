import 'dart:ui';

import '../../extensions.dart';
import '../components/mixins/single_child_particle.dart';
import 'particle.dart';

/// Statically offset given child [Particle] by given [Vector2].
///
/// If you're looking to move the child, consider MovingParticle.
class TranslatedParticle extends Particle with SingleChildParticle {
  @override
  Particle child;

  final Vector2 offset;

  TranslatedParticle({
    required this.child,
    required this.offset,
    double? lifespan,
  }) : super(lifespan: lifespan);

  @override
  void render(Canvas c) {
    c.save();
    c.translateVector(offset);
    super.render(c);
    c.restore();
  }
}
