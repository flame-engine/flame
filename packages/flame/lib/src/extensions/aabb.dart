import 'package:flame/extensions.dart';

extension Aabb2Extension on Aabb2 {
  /// Creates a [Rect] starting in [min] and going the [max]
  Rect toRect() => Rect.fromLTRB(min.x, min.y, max.x, max.y);
}
