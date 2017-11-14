import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

import 'flame.dart';

abstract class Component {

  void update(double t);

  void render(Canvas c);

}

abstract class PositionComponent extends Component {
  double x = 0.0,
      y = 0.0,
      angle = 0.0;

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - PI / 2) % (2 * PI);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

}

abstract class SpriteComponent extends PositionComponent {

  double width, height;
  Image image;

  final Paint paint = new Paint()
    ..color = new Color(0xffffffff);

  SpriteComponent.square(double size, String imagePath)
      : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(this.width, this.height, String imagePath) {
    Flame.images.load(imagePath).then((image) {
      this.image = image;
    });
  }

  render(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle); // TODO: rotate around center
    if (image != null) {
      final Rect outputRect = new Rect.fromLTWH(0.0, 0.0, width, height);

      final Size imageSize = new Size(
          image.width.toDouble(), image.height.toDouble());
      final FittedSizes sizes = applyBoxFit(
          BoxFit.cover, imageSize, outputRect.size);
      final Rect inputSubrect = Alignment.center.inscribe(
          sizes.source, Offset.zero & imageSize);
      final Rect outputSubrect = Alignment.center.inscribe(
          sizes.destination, outputRect);
      canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
    }
  }

  update(double t) {}
}