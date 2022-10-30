import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:vector_math/vector_math_64.dart';

/// An arbitrary polygon with 3 or more vertices.
///
/// The vertices of the polygon are in the counter-clockwise order, so that the
/// polygon's interior is in your left-hand side as you traverse the polygon's
/// vertices.
///
/// A polygon can be either convex or not, the [containsPoint] method will work
/// in both cases, however, the method used with convex polygon is faster.
class Polygon extends Shape {
  /// Constructs the polygon from the given list of vertices.
  ///
  /// If the list is not in the counter-clockwise order, then it will be
  /// reversed in-place.
  ///
  /// If the [convex] flag is provided, then it serves as a hint about whether
  /// the polygon is convex or not. With this flag the user promises that the
  /// vertices are already in the correct CCW order.
  Polygon(this._vertices, {bool? convex})
      : assert(_vertices.length >= 3, 'At least 3 vertices are required') {
    _initializeEdges();
    if (convex == null) {
      _ensureProperOrientation();
    } else {
      _convex = convex;
    }
  }

  /// The vertices (corners) of the polygon.
  ///
  /// The user should treat this list as read-only and not attempt to modify
  /// either the list itself or individual points.
  List<Vector2> get vertices => _vertices;
  final List<Vector2> _vertices;

  /// The edges (sides) of the polygon.
  ///
  /// Each i-th edge is equal to the vector difference between the i-th vertex
  /// and the preceding vertex. The number of edges is always equal to the
  /// number of vertices.
  List<Vector2> get edges => _edges;
  late List<Vector2> _edges;
  void _initializeEdges() {
    var previousVertex = _vertices.last;
    _edges = _vertices.map((Vector2 vertex) {
      final edge = vertex - previousVertex;
      previousVertex = vertex;
      return edge;
    }).toList(growable: false);
  }

  /// Checks whether the vertices are listed in the CCW order, and if not
  /// reverses them. In addition, this method also checks whether the polygon
  /// is convex and sets the [_convex] flag accordingly.
  void _ensureProperOrientation() {
    var nInteriorAngles = 0;
    var nExteriorAngles = 0;
    var previousEdge = _edges.last;
    _edges.forEach((edge) {
      final crossProduct = edge.cross(previousEdge);
      previousEdge = edge;
      // A straight angle counts as both internal and external
      if (crossProduct >= 0) {
        nInteriorAngles++;
      }
      if (crossProduct <= 0) {
        nExteriorAngles++;
      }
    });
    if (nInteriorAngles < nExteriorAngles) {
      _reverseVertices();
      _initializeEdges();
      nInteriorAngles = nExteriorAngles;
    }
    _convex = nInteriorAngles == _vertices.length;
  }

  /// Reverses the list of vertices in-place.
  void _reverseVertices() {
    for (var i = 0, j = _vertices.length - 1; i < j; i++, j--) {
      final tmp = _vertices[i];
      _vertices[i] = _vertices[j];
      _vertices[j] = tmp;
    }
  }

  @override
  bool get isConvex => _convex;
  late bool _convex;

  @override
  Vector2 get center => _center ??= _calculateCenter();
  Vector2? _center;
  Vector2 _calculateCenter() {
    final center = Vector2.zero();
    _vertices.forEach(center.add);
    return center..scale(1 / _vertices.length);
  }

  @override
  double get perimeter => _perimeter ??= _calculatePerimeter();
  double? _perimeter;
  double _calculatePerimeter() => edges.map((e) => e.length).sum;

  @override
  Aabb2 get aabb => _aabb ??= _calculateAabb();
  Aabb2? _aabb;
  Aabb2 _calculateAabb() {
    final aabb = Aabb2.minMax(_vertices.first, _vertices.first);
    _vertices.forEach(aabb.hullPoint);
    return aabb;
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
    if (!aabb.intersectsWithVector2(point)) {
      return false;
    }
    final n = _vertices.length;
    if (isConvex) {
      // For a convex polygon, a point is inside if for each edge the cross-
      // product of that edge and a vector from the edge's origin to the point
      // is positive or zero.
      for (var i = 0; i < n; i++) {
        if ((point - _vertices[i]).cross(_edges[i]) < 0) {
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
        if (vi.x == x0 && vi.y == y0) {
          return true;
        }
        if ((vi.y == y0 && vi.x > x0) ||
            (vj.y == y0 && vj.x > x0) ||
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
  Shape project(Transform2D transform, [Shape? target]) {
    final n = _vertices.length;
    if (target is Polygon && target.vertices.length == n) {
      for (var i = 0; i < n; i++) {
        target._vertices[i].setFrom(transform.localToGlobal(_vertices[i]));
      }
      target._initializeEdges();
      target._convex = _convex;
      if (transform.hasReflection) {
        target._reverseVertices();
        target._initializeEdges();
      }
      return target;
    }
    final newVertices = _vertices
        .map((vertex) => transform.localToGlobal(vertex))
        .toList(growable: false);
    final convex = transform.hasReflection ? null : _convex;
    return Polygon(newVertices, convex: convex);
  }

  @override
  void move(Vector2 offset) {
    _vertices.forEach((vertex) => vertex.add(offset));
    _center?.add(offset);
    _aabb?.min.add(offset);
    _aabb?.max.add(offset);
  }

  @override
  Vector2 support(Vector2 direction) {
    var bestVertex = _vertices.first;
    var bestProduct = bestVertex.dot(direction);
    for (final vertex in _vertices) {
      final dotProduct = vertex.dot(direction);
      if (dotProduct > bestProduct) {
        bestProduct = dotProduct;
        bestVertex = vertex;
      }
    }
    return bestVertex;
  }

  @override
  String toString() => 'Polygon($vertices)';
}
