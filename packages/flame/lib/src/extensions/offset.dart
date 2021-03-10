import 'dart:math';
import 'dart:ui';

import 'vector2.dart';

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
}
