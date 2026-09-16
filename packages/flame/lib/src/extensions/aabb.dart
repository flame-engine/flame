import 'package:flame/extensions.dart';

extension Aabb2Extension on Aabb2 {
  /// Creates a [Rect] starting in [min] and going the [max]
  Rect toRect() => Rect.fromLTRB(min.x, min.y, max.x, max.y);

  /// Creates an [Aabb2] from an [offsets] list.
  static Aabb2 fromOffsets(List<Offset> offsets) {
    if (offsets.isEmpty) {
      return Aabb2();
    }
    final first = offsets.first.toVector2();
    final box = Aabb2.minMax(first, first);
    if (offsets.length > 1) {
      offsets.forEach((offset) => box.hullPoint(offset.toVector2()));
    }
    return box;
  }
}
