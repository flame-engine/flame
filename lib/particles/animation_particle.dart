import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../animation.dart';
import '../particle.dart';
import '../position.dart';

class AnimationParticle extends Particle {
  final Animation animation;
  final Position size;
  final Paint overridePaint;
  final bool alignAnimationTime;

  AnimationParticle({
    @required this.animation,
    this.size,
    this.overridePaint,
    double lifespan,
    Duration duration,
    this.alignAnimationTime = true,
  }) : super(
          lifespan: lifespan,
          duration: duration,
        );

  @override
  void setLifespan(double lifespan) {
    super.setLifespan(lifespan);

    if (alignAnimationTime) {
      animation.stepTime = lifespan / animation.frames.length;
      animation.reset();
    }
  }

  @override
  void render(Canvas canvas) {
    animation.getSprite().renderCentered(canvas, Position.empty(), 
      overridePaint: overridePaint,
      size: size
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation.update(dt);
  }
}