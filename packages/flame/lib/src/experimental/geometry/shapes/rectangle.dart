import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/experimental/geometry/shapes/polygon.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:flame/src/math/random_fallback.dart';

/// An axis-aligned rectangle.
///
/// This is similar to ui [Rect], except that this class is mutable and
/// conforms to the [Shape] API.
///
/// Unlike with [Rect], the [Rectangle] is always correctly oriented, in the
/// sense that its left edge is to the left from the right edge, and its top
/// edge is above the bottom edge.
///
/// The edges of a [Rectangle] can also coincide: the left edge can coincide
/// with the right edge, and the top side with the bottom.
class Rectangle extends Shape {
  /// Constructs the [Rectangle] from left, top, right and bottom edges.
  ///
  /// If the edges are given in the wrong order (e.g. `left` is to the right
  /// from `right`), then they will be swapped.
  Rectangle.fromLTRB(this._left, this._top, this._right, this._bottom) {
    if (_left > _right) {
      final tmp = _left;
      _left = _right;
      _right = tmp;
    }
    if (_top > _bottom) {
      final tmp = _top;
      _top = _bottom;
      _bottom = tmp;
    }
  }

  Rectangle.fromLTWH(double left, double top, double width, double height)
    : this.fromLTRB(left, top, left + width, top + height);

  /// Constructs a [Rectangle] from two opposite corners. The points can be in
  /// any disposition to each other.
  factory Rectangle.fromPoints(Vector2 a, Vector2 b) =>
      Rectangle.fromLTRB(a.x, a.y, b.x, b.y);

  /// Constructs a [Rectangle] from a [Rect].
  factory Rectangle.fromRect(Rect rect) =>
      Rectangle.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);

  /// Constructs a [Rectangle] from a center point and a size.
  factory Rectangle.fromCenter({
    required Vector2 center,
    required Vector2 size,
  }) {
    final halfSize = size / 2;
    return Rectangle.fromPoints(
      center - halfSize,
      center + halfSize,
    );
  }

  double _left;
  double _top;
  double _right;
  double _bottom;

  double get left => _left;
  double get right => _right;
  double get top => _top;
  double get bottom => _bottom;
  double get width => _right - _left;
  double get height => _bottom - _top;

  @override
  Aabb2 get aabb => _aabb ??= _calculateAabb();
  Aabb2? _aabb;
  Aabb2 _calculateAabb() {
    return Aabb2.minMax(Vector2(_left, _top), Vector2(_right, _bottom));
  }

  @override
  bool get isConvex => true;

  @override
  Vector2 get center => Vector2((_left + _right) / 2, (_top + _bottom) / 2);

  @override
  double get perimeter => 2 * (width + height);

  double get area => width * height;

  @override
  Path asPath() {
    return Path()..addRect(Rect.fromLTRB(_left, _top, _right, _bottom));
  }

  @override
  bool containsPoint(Vector2 point) {
    return point.x >= _left &&
        point.y >= _top &&
        point.x <= _right &&
        point.y <= _bottom;
  }

  @override
  Shape project(Transform2D transform, [Shape? target]) {
    if (transform.isAxisAligned) {
      final v1 = transform.localToGlobal(Vector2(_left, _top));
      final v2 = transform.localToGlobal(Vector2(_right, _bottom));
      final newLeft = min(v1.x, v2.x);
      final newRight = max(v1.x, v2.x);
      final newTop = min(v1.y, v2.y);
      final newBottom = max(v1.y, v2.y);
      if (target is Rectangle) {
        target._left = newLeft;
        target._right = newRight;
        target._top = newTop;
        target._bottom = newBottom;
        target._aabb = null;
        return target;
      } else {
        return Rectangle.fromLTRB(newLeft, newTop, newRight, newBottom);
      }
    }
    throw UnimplementedError();
  }

  @override
  void move(Vector2 offset) {
    _left += offset.x;
    _right += offset.x;
    _top += offset.y;
    _bottom += offset.y;
    _aabb?.min.add(offset);
    _aabb?.max.add(offset);
  }

  @override
  Vector2 support(Vector2 direction) {
    final vx = direction.x >= 0 ? _right : _left;
    final vy = direction.y >= 0 ? _bottom : _top;
    return Vector2(vx, vy);
  }

  static final Vector2 _tmpResult = Vector2.zero();

  @override
  Vector2 nearestPoint(Vector2 point) {
    return _tmpResult..setValues(
      (point.x).clamp(_left, _right),
      (point.y).clamp(_top, _bottom),
    );
  }

  Rect toRect() => Rect.fromLTWH(left, top, width, height);

  /// Returns all intersections between this rectangle's edges and the given
  /// line segment.
  Set<Vector2> intersections(LineSegment line) {
    return edges.expand((e) => e.intersections(line)).toSet();
  }

  @override
  Vector2 randomPoint({Random? random, bool within = true}) {
    final randomGenerator = random ?? randomFallback;
    if (within) {
      return Vector2(
        left + randomGenerator.nextDouble() * width,
        top + randomGenerator.nextDouble() * height,
      );
    } else {
      return Polygon.randomPointAlongEdges(vertices, random: randomGenerator);
    }
  }

  /// The 4 edges of this rectangle, returned in a clockwise fashion.
  List<LineSegment> get edges => [topEdge, rightEdge, bottomEdge, leftEdge];

  LineSegment get topEdge => LineSegment(topLeft, topRight);
  LineSegment get rightEdge => LineSegment(topRight, bottomRight);
  LineSegment get bottomEdge => LineSegment(bottomRight, bottomLeft);
  LineSegment get leftEdge => LineSegment(bottomLeft, topLeft);

  /// The 4 corners of this rectangle, returned in a clockwise fashion.
  List<Vector2> get vertices => [topLeft, topRight, bottomRight, bottomLeft];

  Vector2 get topLeft => Vector2(left, top);
  Vector2 get topRight => Vector2(right, top);
  Vector2 get bottomRight => Vector2(right, bottom);
  Vector2 get bottomLeft => Vector2(left, bottom);

  @override
  String toString() => 'Rectangle([$_left, $_top], [$_right, $_bottom])';
}
