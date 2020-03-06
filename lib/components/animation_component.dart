import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/animation.dart';
import 'package:flame/anchor.dart';

class AnimationComponent extends PositionComponent {
  Animation animation;
  bool destroyOnFinish;

  AnimationComponent(
      this.animation,
      {
        double x = 0.0,
        double y = 0.0,
        double angle = 0.0,
        double width,
        double height,
        Anchor anchor = Anchor.topLeft,
        bool renderFlipX = false,
        bool renderFlipY = false,
        this.destroyOnFinish = false,
      }
  ) {
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.width = width ?? animation.frames.first?.sprite.src?.width ?? 0.0;
    this.height = height ?? animation.frames.first?.sprite.src?.height ?? 0.0;
    this.anchor = anchor;
    this.renderFlipX = renderFlipX;
    this.renderFlipY = renderFlipY;
  }

  AnimationComponent.empty();

  @override
  bool loaded() => animation.loaded();

  @override
  bool destroy() => destroyOnFinish && animation.isLastFrame;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animation.getCurrentSprite().render(canvas, width: width, height: height);
  }

  @override
  void update(double t) {
    animation.update(t);
  }
}
