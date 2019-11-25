import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../particles/curved_particle.dart';
import '../mixins/single_child_particle.dart';
import '../particle_component.dart';

/// Statically offset given child [Particle] by given [Offset]
/// If you're loking to move the child, consider [MovingParticle]
class MovingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Offset from;
  final Offset to;

  MovingParticle({
    @required this.child,
    @required this.to,
    this.from = Offset.zero,
    double lifespan,
    Duration duration,
    Curve curve = Curves.linear,
  }) : super(
          lifespan: lifespan,
          duration: duration,
          curve: curve,
        );

  @override
  void render(Canvas c) {
    c.save();
    final Offset current = Offset.lerp(from, to, progress);
    c.translate(current.dx, current.dy);
    super.render(c);
    c.restore();
  }
}
