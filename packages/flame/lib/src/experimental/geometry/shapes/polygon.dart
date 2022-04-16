import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../../../game/transform2d.dart';
import 'shape.dart';

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
    _edges = _calculateEdges();
    if (convex == null) {
      _checkOrientation();
    } else {
      _convex = convex;
    }
  }

  /// The vertices (corners) of the polygon.
  ///
  /// Neither the list nor individuals vertices can be modified by the user.
  List<Vector2> get vertices => _vertices;
  final List<Vector2> _vertices;

  /// The edges (sides) of the polygon.
  ///
  /// Each `edges[i]` is equal to `vertices[i] - vertices[i-1]`.
  List<Vector2> get edges => _edges;
  late final List<Vector2> _edges;

  /// Number of vertices/edges in the polygon.
  int get n => _vertices.length;

  List<Vector2> _calculateEdges() {
    var previousVertex = _vertices.last;
    return _vertices.map((Vector2 vertex) {
      final edge = vertex - previousVertex;
      previousVertex = vertex;
      return edge;
    }).toList(growable: false);
  }

  void _checkOrientation() {
    var nInteriorAngles = 0;
    var nExteriorAngles = 0;
    var previousEdge = _edges.last;
    _edges.forEach((edge) {
      final crossProduct = edge.cross(previousEdge);
      previousEdge = edge;
      if (crossProduct >= 0) {
        nInteriorAngles++;
      }
      if (crossProduct <= 0) {
        nExteriorAngles++;
      }
    });
    final n = _vertices.length;
    if (nInteriorAngles < nExteriorAngles) {
      _reverseVertices(_vertices);
      _reverseEdges(_edges);
      nInteriorAngles = nExteriorAngles;
    }
    _convex = nInteriorAngles == n;
  }

  static void _reverseVertices(List<Vector2> vertices) {
    final n = vertices.length;
    for (var i = 0; i < n / 2; i++) {
      final j = n - i;
      final tmp = vertices[i];
      vertices[i] = vertices[j];
      vertices[j] = tmp;
    }
  }

  static void _reverseEdges(List<Vector2> edges) {
    edges.forEach((edge) => edge.scale(-1));
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
    return center..scaled(1 / _vertices.length);
  }

  @override
  double get perimeter => _perimeter ??= _calculatePerimeter();
  double? _perimeter;
  double _calculatePerimeter() {
    return _edges.fold<double>(0, (sum, edge) => sum + edge.length);
  }

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
  Shape project(Transform2D transform, [Shape? target]) {
    if (target is Polygon && target.n == n) {
      for (var i = 0; i < n; i++) {
        target._vertices[i].setFrom(transform.localToGlobal(_vertices[i]));
      }
      target._edges = _calculateEdges();
      target._convex = _convex;
      if (transform.hasReflection) {
        _reverseVertices(target._vertices);
        _reverseEdges(target._edges);
      }
      return target;
    }
    final newVertices = _vertices
        .map((vertex) => transform.localToGlobal(vertex))
        .toList(growable: false);
    if (transform.hasReflection) {
      _reverseVertices(newVertices);
    }
    return Polygon(newVertices, convex: _convex);
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
    var bestProduct = -1.0;
    late Vector2 bestVertex;
    for (final vertex in _vertices) {
      final dotProduct = vertex.dot(direction);
      if (dotProduct > bestProduct) {
        bestProduct = dotProduct;
        bestVertex = vertex;
      }
    }
    return bestVertex;
  }
}
