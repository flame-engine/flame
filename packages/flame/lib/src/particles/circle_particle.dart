import 'dart:ui';

import 'package:flame/src/particles/particle.dart';

/// Plain circle with no other behaviors.
///
/// Consider composing this with other [Particle]s to achieve needed effects.
class CircleParticle extends Particle {
  final Paint paint;
  final double radius;

  CircleParticle({
    required this.paint,
    this.radius = 10.0,
    super.lifespan,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
