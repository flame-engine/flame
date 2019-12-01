import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../components/mixins/single_child_particle.dart';
import '../particle.dart';
import 'curved_particle.dart';

/// A particle serves as a container for basic
/// acceleration physics.
/// [Offset] unit is logical px per second.
/// speed = Offset(0, 100) is 100 logical pixels per second, down
/// acceleration = Offset(-40, 0) will accelerate to left at rate of 40 px/s
class AcceleratedParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Offset acceleration;
  Offset speed;
  Offset position;

  AcceleratedParticle({
    @required this.child,
    this.acceleration = Offset.zero,
    this.speed = Offset.zero,
    this.position = Offset.zero,
    double lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void update(double t) {
    speed += acceleration * t;
    position += speed * t - (acceleration * pow(t, 2)) / 2;

    super.update(t);
  }
}
