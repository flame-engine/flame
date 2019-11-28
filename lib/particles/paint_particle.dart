import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../components/mixins/single_child_particle.dart';
import '../particle.dart';
import 'curved_particle.dart';

/// A particle which renders its child with certain [Paint]
/// Could be used for applying composite effects.
/// Be aware that any composite operation is relatively expensive, as involves
/// copying portions of GPU memory. The less pixels copied - the faster it'll be.
class PaintParticle extends CurvedParticle with SingleChildParticle {
  @override
  Particle child;

  final Paint paint;

  /// Defines Canvas layer bounds
  /// for applying this particle composite effect.
  /// Any child content outside this bounds will be clipped.
  final Rect bounds;

  PaintParticle({
    @required this.child,
    @required this.paint,

    // Reasonably large rect for most particles
    this.bounds = const Rect.fromLTRB(-50, -50, 50, 50),
    double lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(bounds, paint);
    super.render(canvas);
    canvas.restore();
  }
}
