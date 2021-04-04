import 'dart:ui';

import 'particle.dart';

/// Plain circle with no other behaviors.
///
/// Consider composing this with other [Particle]s to achieve needed effects.
class CircleParticle extends Particle {
  final Paint paint;
  final double radius;

  CircleParticle({
    required this.paint,
    this.radius = 10.0,
    double? lifespan,
  }) : super(lifespan: lifespan);

  @override
  void render(Canvas c) {
    c.drawCircle(Offset.zero, radius, paint);
  }
}
