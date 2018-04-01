import 'dart:math' as math;
import 'sprite.dart';

class Animation {
  List<Sprite> sprites;
  double stepTime = 0.1;
  double lifeTime = 0.0;
  bool loop = true;

  Animation() {
    this.sprites = [];
  }

  Animation.spriteList(this.sprites, {this.stepTime, this.lifeTime});

  Animation.sequenced(String imagePath, int amount,
      {double textureX = 0.0,
      double textureY = 0.0,
      double textureWidth = -1.0,
      double textureHeight = -1.0}) {
    sprites = new List<Sprite>(amount);
    for (var i = 0; i < amount; i++) {
      sprites[i] = new Sprite(imagePath,
          x: textureX + i * textureWidth,
          y: textureY,
          width: textureWidth,
          height: textureHeight);
    }
  }

  Sprite getSprite() {
    int i = (lifeTime / stepTime).round();
    return sprites[loop ? i % sprites.length : math.min(i, sprites.length - 1)];
  }

  void update(double t) {
    this.lifeTime += t;
  }

  bool loaded() {
    return !sprites.any((sprite) => !sprite.loaded());
  }
}
