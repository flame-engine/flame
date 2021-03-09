import 'dart:math';
import 'dart:ui';

import '../../geometry.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import 'shape.dart';

class Polygon extends Shape {
  final List<Vector2> normalizedVertices;

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
    this.normalizedVertices, {
    Vector2? position,
    Vector2? size,
    double? angle,
  }) : super(position: position, size: size, angle: angle ?? 0);

  final _cachedScaledShape = ShapeCache<Iterable<Vector2>>();

  /// Gives back the shape vectors multiplied by the size
  Iterable<Vector2> scaled() {
    if (!_cachedScaledShape.isCacheValid([size])) {
      _cachedScaledShape.updateCache(
        normalizedVertices.map((p) => p.clone()..multiply(size! / 2)),
        [size!.clone()],
      );
    }
    return _cachedScaledShape.value!;
  }

  final _cachedRenderPath = ShapeCache<Path>();

  @override
  void render(Canvas canvas, Paint paint) {
    if (!_cachedRenderPath.isCacheValid([position, size])) {
      _cachedRenderPath.updateCache(
        Path()
          ..addPolygon(
            scaled()
                .map((point) => (point +
                        (position + size! / 2) +
                        ((size! / 2)..multiply(relativePosition)))
                    .toOffset())
                .toList(),
            true,
          ),
        [
          position.clone(),
          size!.clone(),
        ],
      );
    }
    canvas.drawPath(_cachedRenderPath.value!, paint);
  }

  final _cachedHitbox = ShapeCache<List<Vector2>>();

  /// Gives back the vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> hitbox() {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_cachedHitbox.isCacheValid([position, size, angle])) {
      _cachedHitbox.updateCache(
        scaled()
            .map((point) =>
                (point + shapeCenter)..rotate(angle, center: anchorPosition))
            .toList(growable: false),
        [shapeCenter, size!.clone(), angle],
      );
    }
    return _cachedHitbox.value!;
  }

  /// Checks whether the polygon represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    // If the size is 0 then it can't contain any points
    if (size!.x == 0 || size!.y == 0) {
      return false;
    }

    final vertices = hitbox();
    for (var i = 0; i < vertices.length; i++) {
      final edge = getEdge(i, vertices: vertices);
      final isOutside = (edge.to.x - edge.from.x) * (point.y - edge.from.y) -
              (point.x - edge.from.x) * (edge.to.y - edge.from.y) >
          0;
      if (isOutside) {
        // Point is outside of convex polygon
        return false;
      }
    }
    return true;
  }

  /// Return all vertices as [LineSegment]s that intersect [rect], if [rect]
  /// is null return all vertices as [LineSegment]s.
  List<LineSegment> possibleIntersectionVertices(Rect? rect) {
    final rectIntersections = <LineSegment>[];
    final vertices = hitbox();
    for (var i = 0; i < vertices.length; i++) {
      final edge = getEdge(i, vertices: vertices);
      if (rect?.intersectsSegment(edge.from, edge.to) ?? true) {
        rectIntersections.add(edge);
      }
    }
    return rectIntersections;
  }

  LineSegment getEdge(int i, {required List<Vector2> vertices}) {
    return LineSegment(
      getVertex(i, vertices: vertices),
      getVertex(
        i + 1,
        vertices: vertices,
      ),
    );
  }

  Vector2 getVertex(int i, {List<Vector2>? vertices}) {
    vertices ??= hitbox();
    return vertices[i % vertices.length];
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super.fromDefinition(definition);
}
