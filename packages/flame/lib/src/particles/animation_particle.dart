import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';
import 'package:flame/src/sprite_animation.dart';

export '../sprite_animation.dart';
export '../sprite_animation.dart';

class SpriteAnimationParticle extends Particle {
  final SpriteAnimation animation;
  final Vector2? size;
  final Paint? overridePaint;
  final bool alignAnimationTime;

  SpriteAnimationParticle({
    required this.animation,
    this.size,
    this.overridePaint,
    super.lifespan,
    this.alignAnimationTime = true,
  });

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
    animation.getSprite().render(
          canvas,
          size: size,
          anchor: Anchor.center,
          overridePaint: overridePaint,
        );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation.update(dt);
  }
}
