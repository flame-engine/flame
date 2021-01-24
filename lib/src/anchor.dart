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

  /// If the [position] sent in is representing the top left corner, the
  /// position that you will get back is the anchor's position.
  /// For example if you send in Vector2(200, 200) as [position] and
  /// Vector2(100, 100) as [size] and the [Anchor] you are calling this method
  /// on is an Anchor.center, then the result will be Vector2(150, 150), which
  /// is the topLeftPosition that your thing will have to have in order for
  /// [position] to be in the center (or whichever anchor that you are using).
  Vector2 translate(Vector2 position, Vector2 size) {
    return position - (toVector2..multiply(size));
  }
}
