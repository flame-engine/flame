import 'dart:math';

import 'package:flame/extensions.dart';

/// Splits a simple [polygon] into convex polygons of at most [maxVertices]
/// vertices each, like the ones that physics engines such as Box2D need.
///
/// The polygon is split into triangles by ear clipping first, which are then
/// merged with their neighbors as long as they stay convex and within
/// [maxVertices] (the Hertel-Mehlhorn algorithm).
///
/// Physics engines reject the polygons that are too small for their
/// tolerances, so the [polygon] is cleaned up first: of the consecutive
/// vertices closer than [minDistance], only the first one is kept, and the
/// vertices closer than half of it to the line through their neighbors are
/// left out. Then, the pieces narrower than [minWidth] are left out, as well
/// as the ones with fewer than three vertices that are [minDistance] apart.
/// For Box2D, [minDistance] is 4 times its linear slop and [minWidth] twice
/// it, see `b2ComputeHull`.
///
/// The pieces reuse the vertices of the [polygon], in the same direction.
List<List<Vector2>> convexPieces(
  List<Vector2> polygon, {
  int maxVertices = 8,
  double minDistance = 0,
  double minWidth = 0,
}) {
  assert(maxVertices >= 3, 'A piece needs at least three vertices');
  final vertices = _clean(polygon, minDistance);
  final n = vertices.length;
  if (n < 3) {
    return const [];
  }
  // The pieces are worked out on indices of vertices going counterclockwise,
  // that is with a positive area, and turned back into vertices at the end.
  final isClockwise = _doubleArea(vertices) < 0;
  final indices = List.generate(n, (i) => isClockwise ? n - 1 - i : i);
  final pieces = _triangulate(vertices, indices);
  // Corners that are reflex by less than half of the minimum width are
  // accepted as convex, since the engine straightens them anyway.
  _merge(vertices, pieces, maxVertices, minWidth / 2);
  return [
    for (final piece in pieces)
      if (_isWideEnough(vertices, piece, minDistance, minWidth))
        [for (final i in isClockwise ? piece.reversed : piece) vertices[i]],
  ];
}

/// The vertices of the [polygon] without the ones closer than [minDistance]
/// to the previous one, nor the ones closer than half of it to the line
/// through their neighbors.
List<Vector2> _clean(List<Vector2> polygon, double minDistance) {
  final vertices = <Vector2>[];
  for (final vertex in polygon) {
    if (vertices.isEmpty || !_isWelded(vertex, vertices.last, minDistance)) {
      vertices.add(vertex);
    }
  }
  while (vertices.length > 1 &&
      _isWelded(vertices.last, vertices.first, minDistance)) {
    vertices.removeLast();
  }
  var hasRemoved = true;
  while (hasRemoved && vertices.length > 3) {
    hasRemoved = false;
    for (var i = 0; i < vertices.length; i++) {
      final m = vertices.length;
      final a = vertices[(i - 1 + m) % m];
      final b = vertices[i];
      final c = vertices[(i + 1) % m];
      final chord = a.distanceTo(c);
      // A vertex whose neighbors coincide is the tip of a spike.
      final distance = chord == 0
          ? a.distanceTo(b)
          : _cross(a, b, c).abs() / chord;
      if (distance < minDistance / 2) {
        vertices.removeAt(i);
        hasRemoved = true;
        break;
      }
    }
  }
  return vertices;
}

/// Whether the vertices [a] and [b] are the same, or closer than
/// [minDistance].
bool _isWelded(Vector2 a, Vector2 b, double minDistance) {
  final distance = a.distanceTo(b);
  return distance == 0 || distance < minDistance;
}

/// Twice the signed area of the [polygon], positive if it is counterclockwise.
double _doubleArea(List<Vector2> polygon) {
  var area = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % polygon.length];
    area += a.x * b.y - b.x * a.y;
  }
  return area;
}

/// Twice the signed area of the triangle [a], [b], [c], positive if it is
/// counterclockwise, that is if [b] is a convex corner.
double _cross(Vector2 a, Vector2 b, Vector2 c) {
  return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

/// Splits the counterclockwise polygon given by the [indices] of [vertices]
/// into triangles, by clipping its ears.
List<List<int>> _triangulate(List<Vector2> vertices, List<int> indices) {
  final remaining = List.of(indices);
  final triangles = <List<int>>[];
  while (remaining.length >= 3) {
    final ear = _findEar(vertices, remaining);
    if (ear == -1) {
      // Only a polygon that crosses itself has no ears; what is left of it is
      // left out.
      break;
    }
    final m = remaining.length;
    final triangle = [
      remaining[(ear - 1 + m) % m],
      remaining[ear],
      remaining[(ear + 1) % m],
    ];
    remaining.removeAt(ear);
    final [a, b, c] = [for (final i in triangle) vertices[i]];
    // Clipping a collinear vertex leaves no triangle.
    if (_cross(a, b, c) > 0) {
      triangles.add(triangle);
    }
  }
  return triangles;
}

/// The position in [remaining] of a vertex that can be clipped, or -1 if
/// there is none.
///
/// A vertex can be clipped if its corner is not reflex and no other vertex
/// lies within the triangle that it makes with its neighbors. Collinear
/// vertices can be clipped too, as they only make a degenerate triangle.
int _findEar(List<Vector2> vertices, List<int> remaining) {
  final m = remaining.length;
  for (var i = 0; i < m; i++) {
    final a = vertices[remaining[(i - 1 + m) % m]];
    final b = vertices[remaining[i]];
    final c = vertices[remaining[(i + 1) % m]];
    if (_cross(a, b, c) < 0) {
      continue;
    }
    var isEar = true;
    for (final j in remaining) {
      final p = vertices[j];
      if (p == a || p == b || p == c) {
        continue;
      }
      if (_cross(a, b, p) >= 0 &&
          _cross(b, c, p) >= 0 &&
          _cross(c, a, p) >= 0) {
        isEar = false;
        break;
      }
    }
    if (isEar) {
      return i;
    }
  }
  return -1;
}

/// Merges the [pieces] that share an edge, as long as the result is convex
/// within the [tolerance] and has at most [maxVertices] vertices.
void _merge(
  List<Vector2> vertices,
  List<List<int>> pieces,
  int maxVertices,
  double tolerance,
) {
  var hasMerged = true;
  while (hasMerged) {
    hasMerged = false;
    for (var i = 0; i < pieces.length; i++) {
      for (var j = i + 1; j < pieces.length; j++) {
        final merged = _union(pieces[i], pieces[j]);
        if (merged != null &&
            merged.length <= maxVertices &&
            _isConvex(vertices, merged, tolerance)) {
          pieces[i] = merged;
          pieces.removeAt(j);
          hasMerged = true;
          // The grown piece may now be merged with the ones already checked.
          j = i;
        }
      }
    }
  }
}

/// The union of the counterclockwise pieces [a] and [b] if they share an
/// edge, or null otherwise.
List<int>? _union(List<int> a, List<int> b) {
  for (var k = 0; k < a.length; k++) {
    final from = a[k];
    final to = a[(k + 1) % a.length];
    // The shared edge goes the other way around in [b].
    final l = b.indexOf(to);
    if (l == -1 || b[(l + 1) % b.length] != from) {
      continue;
    }
    return [
      // All of [a], starting after the shared edge and ending before it.
      for (var i = 1; i <= a.length; i++) a[(k + i) % a.length],
      // The vertices of [b] that are not on the shared edge.
      for (var i = 2; i < b.length; i++) b[(l + i) % b.length],
    ];
  }
  return null;
}

/// Whether the counterclockwise [piece] has no reflex corners, except for the
/// ones closer than the [tolerance] to the line through their neighbors.
bool _isConvex(List<Vector2> vertices, List<int> piece, double tolerance) {
  final m = piece.length;
  for (var i = 0; i < m; i++) {
    final a = vertices[piece[(i - 1 + m) % m]];
    final b = vertices[piece[i]];
    final c = vertices[piece[(i + 1) % m]];
    if (_cross(a, b, c) < -tolerance * a.distanceTo(c)) {
      return false;
    }
  }
  return true;
}

/// Whether the convex [piece] keeps at least three vertices when the ones
/// closer than [minDistance] to a previous one are left out, and is at least
/// [minWidth] wide.
///
/// The width of a convex polygon is the smallest distance between one of its
/// edges and the vertex farthest from it.
bool _isWideEnough(
  List<Vector2> vertices,
  List<int> piece,
  double minDistance,
  double minWidth,
) {
  final points = <Vector2>[];
  for (final i in piece) {
    final vertex = vertices[i];
    if (!points.any((point) => _isWelded(vertex, point, minDistance))) {
      points.add(vertex);
    }
  }
  if (points.length < 3) {
    return false;
  }
  for (var i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    final length = a.distanceTo(b);
    var farthest = 0.0;
    for (final point in points) {
      farthest = max(farthest, _cross(a, b, point).abs() / length);
    }
    if (farthest < minWidth) {
      return false;
    }
  }
  return true;
}
