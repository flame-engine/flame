import 'package:flame/extensions.dart';

extension Aabb2Extension on Aabb2 {
  /// Creates a [Rect] starting in [min] and going the [max]
  Rect toRect() => Rect.fromLTRB(min.x, min.y, max.x, max.y);

  /// Creates an [Aabb2] from a [vertices] list.
  static Aabb2 fromVertices(List<Vector2> vertices) {
    if (vertices.isEmpty) {
      return Aabb2();
    }
    final first = vertices.first;
    final box = Aabb2.minMax(first, first);
    if (vertices.length > 1) {
      vertices.forEach(box.hullPoint);
    }
    return box;
  }
}
