import 'package:flame/src/particles/particle.dart';
import 'package:flutter/animation.dart';

/// A [Particle] which applies certain [Curve] for
/// easing or other purposes to its [progress] getter.
class CurvedParticle extends Particle {
  final Curve curve;

  CurvedParticle({
    this.curve = Curves.linear,
    super.lifespan,
  });

  @override
  double get progress => curve.transform(super.progress);
}
