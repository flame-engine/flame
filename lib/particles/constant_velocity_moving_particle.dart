import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../particle.dart';
import '../components/mixins/single_child_particle.dart';
import '../particles/curved_particle.dart';

/// Statically offset given child [Particle] by given [Offset]
/// Similar to [MovingParticle], however this moves at a constant velocity
/// It will be destroyed when the lifespan is finished or when it reaches [Offset to]
/// This is useful for games that use bullets or projectiles
class ConstantVelocityMovingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Offset from;
  final Offset to;
  final double velocity;
  double _distanceToTravel;
  bool _hasReachedEnd = false;
  double _distanceTraveled = 0;

  ConstantVelocityMovingParticle({
    @required this.child,
    @required this.to,
    this.from = Offset.zero,
    @required this.velocity,
    double lifespan,
    Curve curve = Curves.linear,
  }) : super(
    lifespan: lifespan,
    curve: curve,
  ) {
    _distanceToTravel = (to - from).distance;
  }

  @override 
  void update(double t) {
    _distanceTraveled += velocity*t;
    if (_distanceTraveled >= _distanceToTravel) {
      _hasReachedEnd = true;
    }
    super.update(t);
  }

  @override
  bool destroy() => _hasReachedEnd || super.destroy();

  @override
  void render(Canvas c) {
    c.save();
    final Offset current = Offset.lerp(from, to, _distanceTraveled/_distanceToTravel);
    c.translate(current.dx, current.dy);
    super.render(c);
    c.restore();
  }
}