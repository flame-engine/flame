import 'dart:ui';

import 'package:flame/src/components/mixins/single_child_particle.dart';
import 'package:flame/src/particles/curved_particle.dart';
import 'package:flame/src/particles/particle.dart';
import 'package:flame/src/particles/scaling_particle.dart';

/// Statically scales the given child [Particle] by given [scale].
///
/// If you're looking to scale the child over time, consider [ScalingParticle].
class ScaledParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final double scale;

  ScaledParticle({
    required this.child,
    this.scale = 1.0,
    super.lifespan,
  });

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(scale);
    super.render(canvas);
    canvas.restore();
  }
}
