import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../time.dart';
import '../particle_component.dart';

/// Plain circle with no other behaviors
/// Consider composing with other [Particle]
/// to achieve needed effects
class CircleParticle extends Particle {
  final Paint paint;
  final double radius;

  CircleParticle({
    @required this.paint,
    this.radius = 10.0,
    double lifespan,
    Duration duration,
  }) : super(
          lifespan: lifespan,
          duration: duration,
        );

  @override
  void render(Canvas c) {
    c.drawCircle(Offset.zero, radius, paint);
  }
}
