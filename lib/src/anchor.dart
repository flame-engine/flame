import 'extensions/vector2.dart';

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

  Vector2 get toVector2 => Vector2(x, y);

  const Anchor(this.x, this.y);

  /// If the position sent in is position for the anchor and the size is the
  /// size of the component (or whatever you are using the Anchor on), the
  /// result of [translate] will be the top left position
  Vector2 translate(Vector2 position, Vector2 size) {
    return position - (toVector2..multiply(size));
  }
}
