import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

class Polygon extends Shape {
  Polygon(this._vertices)
      : assert(_vertices.length >= 3, 'At least 3 vertices are required');

  final List<Vector2> _vertices;

  late final List<Vector2> edges = _calculateEdges();
  List<Vector2> _calculateEdges() {
    var previousVertex = _vertices.last;
    return _vertices.map((Vector2 vertex) {
      final edge = vertex - previousVertex;
      previousVertex = vertex;
      return edge;
    }).toList(growable: false);
  }

  @override
  bool get isConvex => _convex ??= _calculateIsConvex();
  bool? _convex;

  bool _calculateIsConvex() {
    var previousEdge = edges.last;
    return edges.every((edge) {
      final crossProduct = edge.cross(previousEdge);
      previousEdge = edge;
      return crossProduct > 0;
    });
  }

  @override
  Vector2 get center => _center ??= _calculateCenter();
  Vector2? _center;

  Vector2 _calculateCenter() {
    final center = Vector2.zero();
    _vertices.forEach(center.add);
    return center..scaled(1 / _vertices.length);
  }

  @override
  double get perimeter => _perimeter ??= _calculatePerimeter();
  double? _perimeter;

  double _calculatePerimeter() {
    return edges.fold<double>(0, (sum, edge) => sum + edge.length);
  }

  @override
  Aabb2 calculateAabb() {
    final min = _vertices[0].clone();
    final max = _vertices[0].clone();
    for (var i = 1; i < _vertices.length; i++) {
      Vector2.min(min, _vertices[i], min);
      Vector2.max(max, _vertices[i], max);
    }
    return Aabb2.minMax(min, max);
  }

  @override
  Path asPath() {
    final path = Path()..moveTo(_vertices.last.x, _vertices.last.y);
    for (final vertex in _vertices) {
      path.lineTo(vertex.x, vertex.y);
    }
    return path..close();
  }

  @override
  bool containsPoint(Vector2 point) {
    final edges = this.edges;
    final n = _vertices.length;
    if (isConvex) {
      // For a convex polygon, a point is inside if for each edge the cross-
      // product of that edge and a vector from the edge's origin to the point
      // is positive or zero.
      for (var i = 0; i < n; i++) {
        if ((point - _vertices[i]).cross(edges[i]) < 0) {
          return false;
        }
      }
      return true;
    } else {
      // For a non-convex polygon, we can verify that a point is inside using
      // the winding theorem: if a point is inside, then any ray coming out of
      // that point will intersect the polygon an odd number of times. If the
      // point is outside, the number of intersections will be even.
      // In this case we choose a horizontal ray that starts at `point` and
      // goes towards +∞.
      final x0 = point.x;
      final y0 = point.y;
      var intersectionCount = 0;
      var j = n - 1; // index of previous vertex
      for (var i = 0; i < n; i++) {
        final vi = _vertices[i];
        final vj = _vertices[j];
        if ((vi.y == y0 && vi.x >= x0) ||
            (vi.y > y0) != (vj.y > y0) &&
                ((y0 - vj.y) * (vi.x - vj.x) / (vi.y - vj.y) >= (x0 - vj.x))) {
          intersectionCount++;
        }
        j = i;
      }
      return intersectionCount.isOdd;
    }
  }

  @override
  Shape project(Transform2D transform) {
    return Polygon(
      _vertices
          .map((vertex) => transform.localToGlobal(vertex))
          .toList(growable: false),
    );
  }
}
