import 'vector2.dart';

class Anchor {
  static const Anchor topLeft = Anchor(0.0, 0.0);
  static const Anchor topCenter = Anchor(0.5, 0.0);
  static const Anchor topRight = Anchor(1.0, 0.0);
  static const Anchor centerLeft = Anchor(0.0, 0.5);
  static const Anchor center = Anchor(0.5, 0.5);
  static const Anchor centerRight = Anchor(1.0, 0.5);
  static const Anchor bottomLeft = Anchor(0.0, 1.0);
  static const Anchor bottomCenter = Anchor(0.5, 1.0);
  static const Anchor bottomRight = Anchor(1.0, 1.0);

  final double x;
  final double y;

  Vector2 get relativePosition => Vector2(x, y);

  const Anchor(this.x, this.y);

  Vector2 translate(Vector2 p, Vector2 size) {
    return p - relativePosition
      ..multiply(size);
  }
}
