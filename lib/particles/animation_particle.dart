import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../sprite_animation.dart';
import '../particle.dart';
import '../vector2f.dart';

class SpriteAnimationParticle extends Particle {
  final SpriteAnimation animation;
  final Vector2F size;
  final Paint overridePaint;
  final bool alignAnimationTime;

  SpriteAnimationParticle({
    @required this.animation,
    this.size,
    this.overridePaint,
    double lifespan,
    this.alignAnimationTime = true,
  }) : super(
          lifespan: lifespan,
        );

  @override
  void setLifespan(double lifespan) {
    super.setLifespan(lifespan);

    if (alignAnimationTime && lifespan != null) {
      animation.stepTime = lifespan / animation.frames.length;
      animation.reset();
    }
  }

  @override
  void render(Canvas canvas) {
    animation.getSprite().renderCentered(
          canvas,
          Vector2F.zero(),
          overridePaint: overridePaint,
          size: size,
        );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation.update(dt);
  }
}
