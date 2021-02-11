import 'dart:math';
import 'dart:ui';

import '../../components.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

/// The Polygon is defined from the center of the component and with
/// percentages of the size of the component.
/// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
/// This will form a diamond shape within the bounding size box.
/// NOTE: Always define your shape is a clockwise fashion
class Polygon extends Shape {
  final List<Vector2> definition;

  Polygon(
    this.definition, {
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super(position: position, size: size, angle: angle ?? 0);

  /// With this helper method you can create your [Polygon] from absolute
  /// positions instead of percentages. This helper will also calculate the size
  /// and center of the Polygon.
  factory Polygon.fromPositions(
    List<Vector2> positions, {
    double angle = 0,
  }) {
    final center = positions.fold<Vector2>(
          Vector2.zero(),
          (sum, v) => sum + v,
        ) /
        positions.length.toDouble();
    final bottomRight = positions.fold<Vector2>(
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
        positions.map<Vector2>((v) => (v - center)..divide(halfSize)).toList();
    return Polygon(
      definition,
      position: center,
      size: halfSize * 2,
      angle: angle,
    );
  }

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
                  .map((point) => (point + position + size / 2).toOffset())
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
      if (rect?.containsVertex(from, to) ?? true) {
        rectIntersections.add(LineSegment(from, to));
      }
    }
    return rectIntersections;
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super(definition);
}
