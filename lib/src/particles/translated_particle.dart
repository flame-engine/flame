import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/mixins/single_child_particle.dart';
import 'particle.dart';

/// Statically offset given child [Particle] by given [Offset]
/// If you're looking to move the child, consider MovingParticle.
class TranslatedParticle extends Particle with SingleChildParticle {
  @override
  Particle child;
  Offset offset;

  TranslatedParticle({
    required this.child,
    required this.offset,
    double? lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas c) {
    c.save();
    c.translate(offset.dx, offset.dy);
    super.render(c);
    c.restore();
  }
}
