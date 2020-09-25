import 'dart:ui';

import '../animation.dart';
import 'component.dart';

class AnimationComponent extends PositionComponent {
  Animation animation;
  Paint overridePaint;
  bool destroyOnFinish = false;

  AnimationComponent(
    double width,
    double height,
    this.animation, {
    this.destroyOnFinish = false,
  }) {
    this.width = width;
    this.height = height;
  }

  AnimationComponent.empty();

  AnimationComponent.sequenced(
    double width,
    double height,
    String imagePath,
    int amount, {
    int amountPerRow,
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth,
    double textureHeight,
    double stepTime,
    bool loop = true,
    this.destroyOnFinish = false,
  }) {
    this.width = width;
    this.height = height;
    animation = Animation.sequenced(
      imagePath,
      amount,
      amountPerRow: amountPerRow,
      textureX: textureX,
      textureY: textureY,
      textureWidth: textureWidth,
      textureHeight: textureHeight,
      stepTime: stepTime ?? 0.1,
      loop: loop,
    );
  }

  @override
  bool loaded() => animation.loaded();

  @override
  bool destroy() => destroyOnFinish && animation.isLastFrame;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
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
