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
}

extension OffsetListExtension on List<Offset> {
  /// Returns itself as a fixed list of [Vector2] objects.
  List<Vector2> get vertices =>
      map((o) => o.toVector2()).toList(growable: false);

  /// Returns the enclosing area as a [Rect].
  Rect get rectangle => RectExtension.fromOffsets(this);
}
