import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:meta/meta.dart';

import '../components/mixins/single_child_particle.dart';
import '../particles/curved_particle.dart';
import 'particle.dart';

/// Statically offset given child [Particle] by given [Offset]
/// If you're looking to move the child, consider [MovingParticle]
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
    Curve curve = Curves.linear,
  }) : super(
          lifespan: lifespan,
          curve: curve,
        );

  @override
  void render(Canvas c) {
    c.save();
    final current = Offset.lerp(from, to, progress);
    c.translate(current.dx, current.dy);
    super.render(c);
    c.restore();
  }
}
