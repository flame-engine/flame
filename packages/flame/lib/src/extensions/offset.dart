import 'dart:math';
import 'dart:ui';

import 'package:flame/src/extensions/rect.dart';
import 'package:flame/src/extensions/vector2.dart';

export 'dart:ui' show Offset;

extension OffsetExtension on Offset {
  /// Creates an [Vector2] from the [Offset]
  Vector2 toVector2() => Vector2(dx, dy);

  /// Creates a [Size] from the [Offset]
  Size toSize() => Size(dx, dy);

  /// Creates a [Point] from the [Offset]
  Point toPoint() => Point(dx, dy);

  /// Creates a [Rect] starting in origin and going the [Offset]
  Rect toRect() => Rect.fromLTWH(0, 0, dx, dy);

  /// The squared distance from this [Offset] to the closest point on the line
  /// segment between [from] and [to].
  double distanceToSegmentSquared(Offset from, Offset to) {
    final segmentX = to.dx - from.dx;
    final segmentY = to.dy - from.dy;
    final pointX = dx - from.dx;
    final pointY = dy - from.dy;
    final lengthSquared = segmentX * segmentX + segmentY * segmentY;
    final along = pointX * segmentX + pointY * segmentY;
    if (along <= 0) {
      return pointX * pointX + pointY * pointY;
    }
    if (along >= lengthSquared) {
      final endX = pointX - segmentX;
      final endY = pointY - segmentY;
      return endX * endX + endY * endY;
    }
    final across = pointX * segmentY - pointY * segmentX;
    return across * across / lengthSquared;
  }
}

extension OffsetListExtension on List<Offset> {
  /// Returns itself as a fixed list of [Vector2] objects.
  List<Vector2> get vertices =>
      map((o) => o.toVector2()).toList(growable: false);

  /// Returns the enclosing area as a [Rect].
  Rect get enclosingRectangle => RectExtension.smallestContaining(this);
}
