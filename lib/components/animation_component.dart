import 'dart:ui';

import 'component.dart';
import 'package:flame/animation.dart';

class AnimationComponent extends PositionComponent {
  Animation animation;

  AnimationComponent(double width, double height, this.animation) {
    this.width = width;
    this.height = height;
  }

  AnimationComponent.empty();

  AnimationComponent.sequenced(
    width,
    height,
    String imagePath,
    int amount, {
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth = null,
    double textureHeight = null,
  }) {
    this.width = width;
    this.height = height;
    this.animation = Animation.sequenced(
      imagePath,
      amount,
      textureX: textureX,
      textureY: textureY,
      textureWidth: textureWidth,
      textureHeight: textureHeight,
    );
  }

  @override
  bool loaded() => animation.loaded();

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animation.getSprite().render(canvas, width, height);
  }

  @override
  void update(double t) {
    animation.update(t);
  }
}
