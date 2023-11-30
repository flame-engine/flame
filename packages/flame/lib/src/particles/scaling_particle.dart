import 'dart:ui';

import 'package:flame/src/components/mixins/single_child_particle.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame/src/particles/particle.dart';

/// A particle which scale its child over the lifespan
/// between 1 and a provided scale.
class ScalingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final double to;

  ScalingParticle({
    required this.child,
    this.to = 0,
    super.lifespan,
  });

  double get scale => lerpDouble(1, to, progress) ?? 0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(scale);
    super.render(canvas);
    canvas.restore();
  }
}
