import 'dart:ui';

import 'package:flame/extensions/vector2.dart';
import 'package:flutter/foundation.dart';

import '../sprite_animation.dart';
import 'position_component.dart';

class SpriteAnimationComponent extends PositionComponent {
  SpriteAnimation animation;
  Paint overridePaint;
  bool destroyOnFinish = false;

  SpriteAnimationComponent(
    Vector2 size,
    this.animation, {
    this.destroyOnFinish = false,
  }) {
    super.size.setFrom(size);
  }

  SpriteAnimationComponent.empty();

  SpriteAnimationComponent.sequenced(
    Vector2 size,
    Image image,
    int amount, {
    int amountPerRow,
    Vector2 texturePosition,
    Vector2 textureSize,
    double stepTime,
    bool loop = true,
    this.destroyOnFinish = false,
  }) {
    super.size.setFrom(size);
    texturePosition ??= Vector2.zero();
    animation = SpriteAnimation.sequenced(
      image,
      amount,
      amountPerRow: amountPerRow,
      texturePosition: texturePosition,
      textureSize: textureSize,
      stepTime: stepTime ?? 0.1,
      loop: loop,
    );
  }

  SpriteAnimationComponent.variableSequenced(
    Vector2 size,
    Image image,
    int amount,
    List<double> stepTimes, {
    int amountPerRow,
    Vector2 texturePosition,
    Vector2 textureSize,
    bool loop = true,
  }) {
    super.size.setFrom(size);

    animation = SpriteAnimation.variableSequenced(
      image,
      amount,
      stepTimes,
      amountPerRow: amountPerRow,
      texturePosition: texturePosition,
      textureSize: textureSize,
      loop: loop,
    );
  }

  @override
  bool destroy() => destroyOnFinish && animation.isLastFrame;

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    animation.getSprite().render(
          canvas,
          width: width,
          height: height,
          overridePaint: overridePaint,
        );
  }

  @override
  void update(double t) {
    super.update(t);
    animation.update(t);
  }
}
