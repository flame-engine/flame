import 'dart:math' show min, max;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/geometry.dart';
import 'package:flame/src/extensions/matrix4.dart';
import 'package:flame/src/extensions/offset.dart';
import 'package:flame/src/extensions/vector2.dart';

export 'dart:ui' show Rect;

extension RectExtension on Rect {
  /// Creates an [Offset] from this [Rect]
  Offset toOffset() => Offset(width, height);

  /// Creates a [Vector2] starting in top left and going to (width, height).
  Vector2 toVector2() => Vector2(width, height);

  /// Converts this [Rect] into a [math.Rectangle].
  math.Rectangle toMathRectangle() => math.Rectangle(left, top, width, height);

  /// Converts this [Rect] into a [RectangleComponent].
  RectangleComponent toRectangleComponent() {
    return RectangleComponent.fromRect(this);
  }

  /// Whether this [Rect] contains a [Vector2] point or not
  bool containsPoint(Vector2 point) => contains(point.toOffset());

  /// Whether the segment formed by [pointA] and [pointB] intersects this [Rect]
  bool intersectsSegment(Vector2 pointA, Vector2 pointB) {
    return min(pointA.x, pointB.x) <= right &&
        min(pointA.y, pointB.y) <= bottom &&
        max(pointA.x, pointB.x) >= left &&
        max(pointA.y, pointB.y) >= top;
  }

  /// Whether the [LineSegment] intersects the [Rect]
  bool intersectsLineSegment(LineSegment segment) {
    return intersectsSegment(segment.from, segment.to);
  }

  List<Vector2> toVertices() {
    return [
      topLeft.toVector2(),
      topRight.toVector2(),
      bottomRight.toVector2(),
      bottomLeft.toVector2(),
    ];
  }

  /// Transform Rect using the transformation defined by [matrix].
  ///
  /// **Note:** Rotation matrices will increase the size of the [Rect] but they
  /// will not rotate it as [Rect] does not have any rotational values.
  ///
  /// **Note:** Only non-negative scale transforms are allowed, if a negative
  /// scale is applied it will return a zero-based [Rect].
  ///
  /// **Note:** The transformation will always happen from the center of the
  /// `Rect`.
  Rect transform(Matrix4 matrix) {
    // For performance reasons we are using the same logic from
    // `Matrix4.transform2` but without the extra overhead of creating vectors.
    return Rect.fromLTRB(
      (topLeft.dx * matrix.m11) + (topLeft.dy * matrix.m21) + matrix.m41,
      (topLeft.dx * matrix.m12) + (topLeft.dy * matrix.m22) + matrix.m42,
      (bottomRight.dx * matrix.m11) +
          (bottomRight.dy * matrix.m21) +
          matrix.m41,
      (bottomRight.dx * matrix.m12) +
          (bottomRight.dy * matrix.m22) +
          matrix.m42,
    );
  }

  /// Creates a [Rect] that represents the bounds of the list [pts].
  static Rect getBounds(List<Vector2> pts) {
    final xPoints = pts.map((e) => e.x);
    final yPoints = pts.map((e) => e.y);

    final minX = xPoints.reduce(min);
    final maxX = xPoints.reduce(max);
    final minY = yPoints.reduce(min);
    final maxY = yPoints.reduce(max);
    return Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
  }

  /// Creates a [Rect] that represents the bounds of the list [pts].
  @Deprecated(
    'Use RectExtension.getBounds() instead. This function will be removed '
    'in v1.2.0',
  )
  static Rect fromBounds(List<Vector2> pts) {
    return getBounds(pts);
  }

  /// Constructs a [Rect] with a [width] and [height] around the [center] point.
  static Rect fromCenter({
    required Vector2 center,
    required double width,
    required double height,
  }) {
    return Rect.fromLTRB(
      center.x - width / 2,
      center.y - height / 2,
      center.x + width / 2,
      center.y + height / 2,
    );
  }

  /// Constructs a [Rect] with a [width] and [height] around the [center] point.
  @Deprecated(
    'Use RectExtension.fromCenter() instead. This function will be removed '
    'in v1.2.0',
  )
  static Rect fromVector2Center({
    required Vector2 center,
    required double width,
    required double height,
  }) {
    return fromCenter(center: center, width: width, height: height);
  }
}
