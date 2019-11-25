import 'dart:ui';

import 'package:flame/components/mixins/single_child_particle.dart';
import 'package:flutter/foundation.dart';

import '../../time.dart';
import '../particle_component.dart';

/// Statically offset given child [Particle] by given [Offset]
/// If you're loking to move the child, consider [MovingParticle]
class TranslatedParticle extends Particle with SingleChildParticle {
  @override
  Particle child;
  Offset offset;

  TranslatedParticle({
    @required this.child,
    @required this.offset,
    double lifespan,
    Duration duration,
  }) : super(
          lifespan: lifespan,
          duration: duration,
        );

  @override
  void render(Canvas c) {
    c.save();
    c.translate(offset.dx, offset.dy);
    super.render(c);
    c.restore();
  }
}
