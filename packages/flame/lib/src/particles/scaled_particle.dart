import 'dart:ui';

import 'package:flame/src/components/mixins/single_child_particle.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame/src/particles/particle.dart';

/// A particle which rotates its child over the lifespan
/// between two given bounds in radians
class ScaledParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final double scale;

  ScaledParticle({
    required this.child,
    this.scale = 1.0,
    double? lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(scale);
    super.render(canvas);
    canvas.restore();
  }
}
