import 'dart:math';
import 'dart:ui';

import '../components/mixins/single_child_particle.dart';
import 'curved_particle.dart';
import 'particle.dart';

/// A particle which rotates its child over the lifespan
/// between two given bounds in radians
class RotatingParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final double from;
  final double to;

  RotatingParticle({
    required this.child,
    this.from = 0,
    this.to = 2 * pi,
    double? lifespan,
  }) : super(
          lifespan: lifespan,
        );

  double get angle => lerpDouble(from, to, progress) ?? 0;

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(angle);
    super.render(canvas);
    canvas.restore();
  }
}
