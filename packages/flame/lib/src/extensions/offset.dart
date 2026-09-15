import 'dart:math';
import 'dart:ui';

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

extension FuzzyEqual on Offset {
  /// Returns true if the two offsets are equal up to given [epsilon].
  bool fuzzyEqual(Offset other, {double epsilon = 1e-3}) {
    final fDx = (dx - other.dx).abs();
    final fDy = (dy - other.dy).abs();
    return fDx <= epsilon && fDy <= epsilon;
  }
}

extension OffsetListExtension on List<Offset> {
  /// Removes the last element if it matches the first one.
  /// If the [strict] parameter is `false`, equality checking is carried out
  /// via the above extension.
  bool removeDuplicateLast({bool strict = true, double epsilon = 1e-3}) {
    if (length > 1 &&
        ((strict && first == last) ||
            (!strict && first.fuzzyEqual(last, epsilon: epsilon)))) {
      removeLast();
      return true;
    }
    return false;
  }

  /// Returns itself as a fixed list of [Vector2] objects.
  List<Vector2> get vertices =>
      map((o) => o.toVector2()).toList(growable: false);

  /// Returns the approximate enclosing rectangle.
  Rect get rectangle {
    const epsilon = 1e-6;
    var r = Rect.zero;
    forEach((offset) {
      final p = Rect.fromCenter(
        center: offset,
        width: epsilon,
        height: epsilon,
      );
      if (r.isEmpty) {
        r = p;
      } else {
        r = r.expandToInclude(p);
      }
    });
    return r;
  }
}

extension VerticesList on List<List<Offset>> {
  /// Returns the given subcontour as a vertices list.
  List<Vector2> getVertices([int index = 0]) {
    assert(index >= 0 && index < length, 'Ivalid subcontour index $index');
    return this[index].vertices;
  }
}
