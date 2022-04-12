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
  bool get isClosed => true;

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
  Aabb2 get aabb {
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
  bool containsPoint(Vector2 point, {double epsilon = 0.00001}) {
    final edges = this.edges;
    final n = _vertices.length;
    for (var i = 0; i < n; i++) {
      if ((point - _vertices[i]).cross(edges[i]) < 0) {
        return false;
      }
    }
    return true;
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
