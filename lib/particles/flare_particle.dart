import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../flare_animation.dart';
import '../particle.dart';

@Deprecated("Use flame_flare package instead")
class FlareParticle extends Particle {
  final FlareAnimation flare;

  FlareParticle({
    @required this.flare,
    double lifespan,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(-flare.width / 2, -flare.height / 2);
    flare.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    flare.update(dt);
  }
}
