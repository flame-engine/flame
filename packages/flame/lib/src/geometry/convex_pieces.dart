import 'dart:math';
import 'dart:typed_data';

import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/signed_area.dart';

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
/// The pieces are made of copies of the vertices of the [polygon], going in
/// the same direction, so they can be handed to the consumers that change
/// their vertices in place, like a `PolygonHitbox`.
///
/// The [polygon] may touch itself at its vertices, like the outline of two
/// shapes that meet at a corner, which is split there into simple polygons:
/// a hole that touches the outline at a vertex is filled, though. The parts
/// of a [polygon] that crosses itself may be left out.
///
/// The cost grows about with the square of the number of vertices, so it is
/// meant to be done when loading, not in the game loop. The polygons of a
/// `PathComponent` are already simplified according to their sampling, while
/// a [polygon] made by hand should not have a vertex for each pixel or each
/// tiny step along a curve.
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
  // The pieces are worked out on indices of vertices going clockwise on the
  // screen, that is with a positive signed area, and turned back into
  // vertices at the end.
  final isReversed = signedArea(vertices) < 0;
  final indices = List.generate(n, (i) => isReversed ? n - 1 - i : i);
  final pieces = [
    for (final loop in _splitAtTouches(vertices, indices, minDistance))
      // The loops that go the other way are holes that touch the outline,
      // which the other loops already cover.
      if (signedArea([for (final i in loop) vertices[i]]) > 0)
        ..._triangulate(vertices, loop),
  ];
  _merge(vertices, pieces, maxVertices);
  return [
    for (final piece in pieces)
      if (_isWideEnough(vertices, piece, minDistance, minWidth))
        [
          for (final i in isReversed ? piece.reversed : piece)
            vertices[i].clone(),
        ],
  ];
}

/// Splits the polygon given by the [indices] of [vertices] where it
/// touches itself, that is where two of its vertices that are not
/// consecutive are welded, into loops that do not touch themselves.
///
/// Ear clipping can get stuck on a polygon that touches itself, which would
/// leave the rest of it out.
///
/// The last vertices of a loop that are welded to its first one are left out,
/// like consecutive vertices are, since a loop that was split off ends next to
/// the vertex where the polygon touches itself.
List<List<int>> _splitAtTouches(
  List<Vector2> vertices,
  List<int> indices,
  double minDistance,
) {
  var loop = indices;
  while (loop.length > 1 &&
      _isWelded(vertices[loop.last], vertices[loop.first], minDistance)) {
    loop = loop.sublist(0, loop.length - 1);
  }
  for (var a = 0; a < loop.length; a++) {
    for (var b = a + 2; b < loop.length; b++) {
      if (_isWelded(vertices[loop[a]], vertices[loop[b]], minDistance)) {
        return [
          ..._splitAtTouches(vertices, loop.sublist(a, b), minDistance),
          ..._splitAtTouches(
            vertices,
            [...loop.sublist(b), ...loop.sublist(0, a)],
            minDistance,
          ),
        ];
      }
    }
  }
  return [loop];
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

/// Twice the signed area of the triangle [a], [b], [c], positive if it goes
/// clockwise on the screen, that is if [b] is a convex corner of a polygon
/// that goes clockwise on the screen.
double _cross(Vector2 a, Vector2 b, Vector2 c) {
  return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

/// Splits the polygon given by the [indices] of [vertices], which goes
/// clockwise on the screen, into triangles, by clipping its ears.
///
/// A vertex is an ear if its corner is not reflex and no other vertex lies
/// within the triangle that it makes with its neighbors. Collinear vertices
/// are ears too, as they only make a degenerate triangle. Only the reflex
/// and collinear vertices can be within an ear of a simple polygon, so only
/// those are checked, and clipping an ear only changes whether its two
/// neighbors are ears.
List<List<int>> _triangulate(List<Vector2> vertices, List<int> indices) {
  final m = indices.length;
  final previous = Int32List.fromList([for (var k = 0; k < m; k++) k - 1])
    ..[0] = m - 1;
  final next = Int32List.fromList([for (var k = 0; k < m; k++) k + 1])
    ..[m - 1] = 0;
  Vector2 at(int k) => vertices[indices[k]];
  double turn(int k) => _cross(at(previous[k]), at(k), at(next[k]));

  final isReflex = List.filled(m, false);
  final reflex = <int>[];
  for (var k = 0; k < m; k++) {
    if (turn(k) <= 0) {
      isReflex[k] = true;
      reflex.add(k);
    }
  }
  var reflexCount = reflex.length;
  void setConvex(int k) {
    if (isReflex[k]) {
      isReflex[k] = false;
      reflexCount--;
    }
  }

  bool isEar(int k) {
    if (turn(k) < 0) {
      return false;
    }
    final a = at(previous[k]);
    final b = at(k);
    final c = at(next[k]);
    for (final r in reflex) {
      if (!isReflex[r]) {
        continue;
      }
      final p = at(r);
      if (p == a || p == b || p == c) {
        continue;
      }
      if (_cross(a, b, p) >= 0 &&
          _cross(b, c, p) >= 0 &&
          _cross(c, a, p) >= 0) {
        return false;
      }
    }
    return true;
  }

  final ears = List.generate(m, isEar);
  final triangles = <List<int>>[];
  var remaining = m;
  var k = 0;
  var stepsWithoutEar = 0;
  var isRechecked = false;
  while (remaining >= 3) {
    if (!ears[k]) {
      if (++stepsWithoutEar > remaining) {
        // The vertices on the edges of an ear can keep it from being one
        // until they are clipped, which only its neighbors are checked for.
        // A polygon that crosses itself may have no ears left, while a
        // simple one always has; what is left of it is left out.
        if (isRechecked) {
          break;
        }
        for (var i = 0, j = k; i < remaining; i++, j = next[j]) {
          ears[j] = isEar(j);
        }
        isRechecked = true;
        stepsWithoutEar = 0;
      }
      k = next[k];
      continue;
    }
    final before = previous[k];
    final after = next[k];
    // Clipping a collinear vertex leaves no triangle.
    if (turn(k) > 0) {
      triangles.add([indices[before], indices[k], indices[after]]);
    }
    next[before] = after;
    previous[after] = before;
    setConvex(k);
    remaining--;
    // A neighbor can only turn from reflex to convex, never the other way.
    if (turn(before) > 0) {
      setConvex(before);
    }
    if (turn(after) > 0) {
      setConvex(after);
    }
    // The vertices that are no longer reflex are dropped from the list once
    // they make up most of it.
    if (reflex.length > 2 * reflexCount + 32) {
      reflex.removeWhere((r) => !isReflex[r]);
    }
    ears[before] = isEar(before);
    ears[after] = isEar(after);
    stepsWithoutEar = 0;
    isRechecked = false;
    k = after;
  }
  return triangles;
}

/// Merges the [pieces] that share an edge, as long as the result is convex
/// and has at most [maxVertices] vertices.
///
/// The neighbors of a piece are found through the edges that it shares with
/// them, which go the other way around in the neighbor.
void _merge(List<Vector2> vertices, List<List<int>> pieces, int maxVertices) {
  final n = vertices.length;
  final owners = <int, int>{};
  void own(int piece) {
    final indices = pieces[piece];
    for (var k = 0; k < indices.length; k++) {
      owners[indices[k] * n + indices[(k + 1) % indices.length]] = piece;
    }
  }

  for (var i = 0; i < pieces.length; i++) {
    own(i);
  }
  final isMerged = List.filled(pieces.length, false);
  for (var i = 0; i < pieces.length; i++) {
    if (isMerged[i]) {
      continue;
    }
    var hasMerged = true;
    while (hasMerged) {
      hasMerged = false;
      final piece = pieces[i];
      for (var k = 0; k < piece.length; k++) {
        final j = owners[piece[(k + 1) % piece.length] * n + piece[k]];
        if (j == null || j == i || isMerged[j]) {
          continue;
        }
        final merged = _union(piece, pieces[j]);
        if (merged != null &&
            merged.length <= maxVertices &&
            _isConvex(vertices, merged)) {
          pieces[i] = merged;
          isMerged[j] = true;
          own(i);
          hasMerged = true;
          break;
        }
      }
    }
  }
  var kept = 0;
  for (var i = 0; i < pieces.length; i++) {
    if (!isMerged[i]) {
      pieces[kept++] = pieces[i];
    }
  }
  pieces.length = kept;
}

/// The union of the pieces [a] and [b], which go clockwise on the screen, if
/// they share an edge, or null otherwise.
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

/// Whether the [piece], which goes clockwise on the screen, has no reflex
/// corners.
bool _isConvex(List<Vector2> vertices, List<int> piece) {
  final m = piece.length;
  for (var i = 0; i < m; i++) {
    final a = vertices[piece[(i - 1 + m) % m]];
    final b = vertices[piece[i]];
    final c = vertices[piece[(i + 1) % m]];
    if (_cross(a, b, c) < 0) {
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
