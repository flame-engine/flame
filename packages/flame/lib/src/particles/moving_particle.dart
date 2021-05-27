import 'dart:ui';

import 'package:flutter/animation.dart';

import '../../extensions.dart';
import '../components/mixins/single_child_particle.dart';
import '../particles/curved_particle.dart';
import 'particle.dart';

/// Statically move given child [Particle] by given [Vector2].
///
/// If you're looking to move the child, consider the [MovingParticle].
class MovingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Vector2 from;
  final Vector2 to;

  MovingParticle({
    required this.child,
    required this.to,
    Vector2? from,
    double? lifespan,
    Curve curve = Curves.linear,
  })  : from = from ?? Vector2.zero(),
        super(lifespan: lifespan, curve: curve);

  @override
  void render(Canvas c) {
    c.save();
    final current = from.clone()..lerp(to, progress);
    c.translateVector(current);
    super.render(c);
    c.restore();
  }
}
