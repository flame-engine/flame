import 'dart:math';
import 'dart:ui';

import 'vector2.dart';

export 'dart:ui' show Size;

extension SizeExtension on Size {
  /// Creates an [Offset] from the [Size]
  Offset toOffset() => Offset(width, height);

  /// Creates a [Vector2] from the [Size]
  Vector2 toVector2() => Vector2(width, height);

  /// Creates a [Point] from the [Size]
  Point toPoint() => Point(width, height);

  /// Creates a [Rect] from the [Size]
  Rect toRect() => Rect.fromLTWH(0, 0, width, height);
}
