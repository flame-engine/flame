import 'dart:ui';

import 'package:flame/src/anchor.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/particles/particle.dart';
import 'package:flame/src/sprite_animation.dart';
import 'package:flame/src/sprite_animation_ticker.dart';

export '../sprite_animation.dart';

/// A [Particle] which applies certain [SpriteAnimation].
class SpriteAnimationParticle extends Particle {
  final SpriteAnimation animation;
  final SpriteAnimationTicker animationTicker;
  final Vector2? position;
  final Vector2? size;
  final Anchor anchor;
  final Paint? overridePaint;
  final bool alignAnimationTime;

  SpriteAnimationParticle({
    required this.animation,
    this.position,
    this.size,
    this.anchor = Anchor.center,
    this.overridePaint,
    super.lifespan,
    this.alignAnimationTime = true,
  }) : animationTicker = animation.createTicker();

  @override
  void setLifespan(double lifespan) {
    super.setLifespan(lifespan);

    if (alignAnimationTime) {
      animation.stepTime = lifespan / animation.frames.length;
      animationTicker.reset();
    }
  }

  @override
  void render(Canvas canvas) {
    animationTicker.getSprite().render(
      canvas,
      position: position,
      size: size,
      anchor: anchor,
      overridePaint: overridePaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    animationTicker.update(dt);
  }
}
