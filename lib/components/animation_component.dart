import 'dart:ui';

import 'component.dart';
import '../sprite.dart';

class AnimationComponent extends PositionComponent {

  double width, height;

  List<Sprite> sprites;
  double stepTime = 0.1;
  double lifeTime = 0.0;

  AnimationComponent.spriteList(this.width, this.height, this.sprites, { this.stepTime, this.lifeTime });

  AnimationComponent.sequenced(this.width, this.height, String imagePath, int amount, { double textureX = 0.0, double textureY = 0.0, double textureWidth = -1.0, double textureHeight = -1.0}) {
    if (textureWidth == -1) {
      textureWidth = this.width;
    }
    if (textureHeight == -1) {
      textureHeight = this.height;
    }
    sprites = new List<Sprite>(amount);
    for (var i = 0; i < amount; i++) {
      sprites[i] = new Sprite(imagePath, x: textureX + i*textureWidth, y: textureY, width: textureWidth, height: textureHeight);
    }
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);

    int i = (lifeTime / stepTime).round();
    sprites[i % sprites.length].render(canvas, width, height);
  }

  @override
  void update(double t) {
    this.lifeTime += t;
  }
}
