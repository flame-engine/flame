import 'dart:math';
import 'dart:ui';

import '../../components.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

class Polygon extends Shape {
  final List<Vector2> definition;

  /// With this constructor you create your [Polygon] from positions in your
  /// intended space. It will automatically calculate the [size] and center
  /// ([position]) of the Polygon.
  factory Polygon(
    List<Vector2> points, {
    double angle = 0,
  }) {
    final center = points.fold<Vector2>(
          Vector2.zero(),
          (sum, v) => sum + v,
        ) /
        points.length.toDouble();
    final bottomRight = points.fold<Vector2>(
      Vector2.zero(),
      (bottomRight, v) {
        return Vector2(
          max(bottomRight.x, v.x),
          max(bottomRight.y, v.y),
        );
      },
    );
    final halfSize = bottomRight - center;
    final definition =
        points.map<Vector2>((v) => (v - center)..divide(halfSize)).toList();
    return Polygon.fromDefinition(
      definition,
      position: center,
      size: halfSize * 2,
      angle: angle,
    );
  }

  /// With this constructor you define the [Polygon] from the center of and with
  /// percentages of the size of the shape.
  /// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
  /// This will form a diamond shape within the bounding size box.
  /// NOTE: Always define your shape is a clockwise fashion
  Polygon.fromDefinition(
    this.definition, {
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super(position: position, size: size, angle: angle ?? 0);

  final _cachedScaledShape = ShapeCache<Iterable<Vector2>>();

  /// Gives back the shape vectors multiplied by the size
  Iterable<Vector2> get scaled {
    if (!_cachedScaledShape.isCacheValid(<dynamic>[size])) {
      _cachedScaledShape.updateCache(
          () => definition?.map((p) => p.clone()..multiply(size / 2)),
          <dynamic>[size.clone()]);
    }
    return _cachedScaledShape.value;
  }

  final _cachedRenderPath = ShapeCache<Path>();

  @override
  void render(Canvas canvas, Paint paint) {
    if (!_cachedRenderPath.isCacheValid(<dynamic>[position, size])) {
      _cachedRenderPath.updateCache(
          () => Path()
            ..addPolygon(
              scaled
                  .map((point) => (point +
                          (position + size / 2) +
                          ((size / 2)..multiply(relativePosition)))
                      .toOffset())
                  .toList(),
              true,
            ),
          <dynamic>[position.clone(), size.clone()]);
    }
    canvas.drawPath(_cachedRenderPath.value, paint);
  }

  final _cachedHitbox = ShapeCache<List<Vector2>>();

  /// Gives back the vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> get hitbox {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_cachedHitbox.isCacheValid(<dynamic>[position, size, angle])) {
      _cachedHitbox.updateCache(() {
        return scaled
                .map((point) => (point + shapeCenter)
                  ..rotate(angle, center: anchorPosition))
                .toList(growable: false) ??
            [];
      }, <dynamic>[shapeCenter, size.clone(), angle]);
    }
    return _cachedHitbox.value;
  }

  /// Checks whether the polygon represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    // If the size is 0 then it can't contain any points
    if (size.x == 0 || size.y == 0) {
      return false;
    }

    for (int i = 0; i < hitbox.length; i++) {
      final previousNode = hitbox[i];
      final node = hitbox[(i + 1) % hitbox.length];
      final isOutside = (node.x - previousNode.x) * (point.y - previousNode.y) -
              (point.x - previousNode.x) * (node.y - previousNode.y) >
          0;
      if (isOutside) {
        // Point is outside of convex polygon
        return false;
      }
    }
    return true;
  }

  /// Return all [vertices] as [LineSegment]s that intersect [rect], if [rect]
  /// is null return all [vertices] as [LineSegment]s.
  List<LineSegment> possibleIntersectionVertices(Rect rect) {
    final List<LineSegment> rectIntersections = [];
    final vertices = hitbox;
    for (int i = 0; i < vertices.length; i++) {
      final from = vertices[i];
      final to = vertices[(i + 1) % vertices.length];
      if (rect?.intersectsSegment(from, to) ?? true) {
        rectIntersections.add(LineSegment(from, to));
      }
    }
    return rectIntersections;
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super.fromDefinition(definition);
}
