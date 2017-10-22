import 'dart:ui';
import 'dart:math';

import 'flame.dart';

abstract class Component {

  void update(double t);
  void render(Canvas c);

}

abstract class SpriteComponent extends Component {

  double x, y, angle;

  double size;
  Image image;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent(this.size, String imagePath) {
    Flame.images.load(imagePath).then((image) { this.image = image; });
  }

  render(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(PI /2 + angle);
    canvas.translate(-size/2, -size/2);
    if (image != null) {
      Rect src = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
      Rect dst = new Rect.fromLTWH(0.0, 0.0, size, size);
      canvas.drawImageRect(image, src, dst, paint);
    }
  }

  update(double t) {}
}