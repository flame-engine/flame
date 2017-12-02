import 'dart:math';
import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';

abstract class Component {
  void update(double t);

  void render(Canvas c);

  bool loaded() {
    return true;
  }

  bool destroy() {
    return false;
  }
}

abstract class PositionComponent extends Component {
  double x = 0.0, y = 0.0, angle = 0.0;

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - PI / 2) % (2 * PI);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle); // TODO: rotate around center
  }
}

class SpriteComponent extends PositionComponent {
  double width, height;
  Sprite sprite;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent.square(double size, String imagePath) : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(this.width, this.height, String imagePath) {
    this.sprite = new Sprite(imagePath);
  }

  SpriteComponent.fromSprite(this.width, this.height, this.sprite);

  @override
  render(Canvas canvas) {
    if (sprite.loaded()) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
    }
  }

  @override
  bool loaded() {
    return this.sprite.loaded();
  }

  @override
  void update(double t) {
  }
}

