import 'dart:math';
import 'dart:ui';

import '../sprite.dart';
import '../position.dart';
import 'package:flutter/painting.dart';

abstract class Component {
  void update(double t);

  void render(Canvas c);

  void resize(Size size) {}

  bool loaded() {
    return true;
  }

  bool destroy() {
    return false;
  }

  bool isHud() {
    return false;
  }
}

abstract class PositionComponent extends Component {
  double x = 0.0, y = 0.0, angle = 0.0;
  double width = 0.0, height = 0.0;

  Position toPosition() => new Position(x, y);
  void setByPosition(Position position) {
    this.x = position.x;
    this.y = position.y;
  }

  Position toSize() => new Position(width, height);
  void setBySize(Position size) {
    this.width = size.x;
    this.height = size.y;
  }

  Rect toRect() => new Rect.fromLTWH(x, y, width, height);
  void setByRect(Rect rect) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
  }

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - pi / 2) % (2 * pi);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);

    // rotate around center
    canvas.translate(width / 2, height / 2);
    canvas.rotate(angle);
    canvas.translate(-width / 2, -height / 2);
  }
}

class SpriteComponent extends PositionComponent {
  Sprite sprite;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent();

  SpriteComponent.square(double size, String imagePath)
      : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(double width, double height, String imagePath)
      : this.fromSprite(width, height, new Sprite(imagePath));

  SpriteComponent.fromSprite(double width, double height, this.sprite) {
    this.width = width;
    this.height = height;
  }

  @override
  render(Canvas canvas) {
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
    }
  }

  @override
  bool loaded() {
    return this.sprite.loaded();
  }

  @override
  void update(double t) {}
}
