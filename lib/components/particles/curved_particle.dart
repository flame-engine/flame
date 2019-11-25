import 'package:flutter/animation.dart';

import '../particle_component.dart';

class CurvedParticle extends Particle {
  final Curve curve;

  CurvedParticle({ 
    this.curve = Curves.linear,
    double lifespan,
    Duration duration,
  }) : super(lifespan: lifespan, duration: duration);

  @override
  double get progress => curve.transform(super.progress);
}