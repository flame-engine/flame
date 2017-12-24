import 'dart:ui';

import 'component.dart';
import 'animation.dart';
import '../sprite.dart';

class AnimationComponent extends PositionComponent {

  Animation animation;

  AnimationComponent(double width, double height, this.animation) {
    this.width = width;
    this.height = height;
  }

  AnimationComponent.sequenced(width, height, String imagePath, int amount, { double textureX = 0.0, double textureY = 0.0, double textureWidth = -1.0, double textureHeight = -1.0}) {
    this.width = width;
    this.height = height;

    if (textureWidth == -1) {
      textureWidth = this.width;
    }
    if (textureHeight == -1) {
      textureHeight = this.height;
    }

    animation = new Animation();
    animation.sprites = new List<Sprite>(amount);
    for (var i = 0; i < amount; i++) {
      animation.sprites[i] = new Sprite(imagePath, x: textureX + i*textureWidth, y: textureY, width: textureWidth, height: textureHeight);
    }
  }

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
