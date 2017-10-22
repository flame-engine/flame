import 'dart:ui';
import 'dart:math';

import 'flame.dart';

abstract class Component {

  void update(double t);
  void render(Canvas c);

}

abstract class PositionComponent extends Component {
  double x, y, angle;

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - PI/2) % (2*PI);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

}

abstract class SpriteComponent extends PositionComponent {

  double width, height;
  Image image;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent.square(double size, String imagePath) : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(this.width, this.height, String imagePath) {
    Flame.images.load(imagePath).then((image) { this.image = image; });
  }

  render(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(PI/2 + angle);
    canvas.translate(-width/2, -height/2);
    if (image != null) {
      Rect src = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
      Rect dst = new Rect.fromLTWH(0.0, 0.0, width, height);
      canvas.drawImageRect(image, src, dst, paint);
    }
  }

  update(double t) {}
}