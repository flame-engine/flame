import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart';

/// Nearest walkable polygon query result returned by
/// [NavMesh3D.findNearestPoly].
class NavPolyHit3D({
  required final int polyIndex,
  required final Vector3 point,
  required final double distanceSquared,
});

/// Directed shared edge portal from one walkable triangle into an adjacent
/// walkable triangle.
class NavPortal3D({
  required final int targetPoly,
  required final Vector3 left,
  required final Vector3 right,
  required final double cost,
});

/// A single walkable triangle polygon inside a [NavMesh3D].
class NavPoly3D({
  required final int index,
  required final int v0,
  required final int v1,
  required final int v2,
  required final Vector3 centroid,
  required final Vector3 normal,
  required final List<NavPortal3D> portals,
});

/// 3D triangle navigation mesh built from any [Mesh] (including
/// [TerrainMesh3D], multi-level bridges/ramps, and custom level meshes),
/// featuring spatial vertex welding, portal adjacency, A* corridor search, and
/// 3D Simple Stupid Funnel string-pulling with elevation draping.
class NavMesh3D._({
  required final List<Vector3> vertices,
  required final List<NavPoly3D> polygons,
  required Vector3 upAxis,
}) {
  this {
    if (this.upAxis.x.abs() < 0.9) {
      _basisU.setValues(1.0, 0.0, 0.0);
    } else {
      _basisU.setValues(0.0, 1.0, 0.0);
    }
    _basisU
      ..addScaled(this.upAxis, -_basisU.dot(this.upAxis))
      ..normalize();
    _basisV.setFrom(this.upAxis.cross(_basisU)..normalize());
  }

  /// Extracts walkable triangles (`normal.dot(up) >= cos(maxSlopeAngleRad)`)
  /// from [mesh] (optionally transformed by [transform]), welds vertices within
  /// [weldEpsilon], and builds triangle portal adjacency.
  factory NavMesh3D.fromMesh(
    Mesh mesh, {
    Matrix4? transform,
    Vector3? upAxis,
    double maxSlopeAngleRad = 0.8,
    double weldEpsilon = 1e-3,
  }) {
    final up = (upAxis?.clone() ?? Vector3(0.0, 1.0, 0.0))..normalize();
    final minCos = math.cos(maxSlopeAngleRad);
    final eps = math.max(1e-7, weldEpsilon);
    final eps2 = eps * eps;
    final invCell = 1.0 / eps;

    final weldedVerts = <Vector3>[];
    final spatialHash = <(int, int, int), List<int>>{};

    int weldVertex(double wx, double wy, double wz) {
      final cx = (wx * invCell).floor();
      final cy = (wy * invCell).floor();
      final cz = (wz * invCell).floor();
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          for (var dz = -1; dz <= 1; dz++) {
            final bucket = spatialHash[(cx + dx, cy + dy, cz + dz)];
            if (bucket == null) {
              continue;
            }
            for (var k = 0; k < bucket.length; k++) {
              final idx = bucket[k];
              final existing = weldedVerts[idx];
              final ex = existing.x - wx;
              final ey = existing.y - wy;
              final ez = existing.z - wz;
              if (ex * ex + ey * ey + ez * ez <= eps2) {
                return idx;
              }
            }
          }
        }
      }
      final newIdx = weldedVerts.length;
      weldedVerts.add(Vector3(wx, wy, wz));
      (spatialHash[(cx, cy, cz)] ??= <int>[]).add(newIdx);
      return newIdx;
    }

    final m = transform?.storage;
    final rawPolys = <(int, int, int, Vector3, Vector3)>[];

    for (final surface in mesh.surfaces) {
      if (surface.indexCount < 3) {
        continue;
      }
      final pos = surface.positions;
      final indices = surface.indices;
      final triCount = indices.length ~/ 3;

      for (var t = 0; t < triCount; t++) {
        final base = t * 3;
        final raw0 = indices[base] * 3;
        final raw1 = indices[base + 1] * 3;
        final raw2 = indices[base + 2] * 3;

        var x0 = pos[raw0];
        var y0 = pos[raw0 + 1];
        var z0 = pos[raw0 + 2];
        var x1 = pos[raw1];
        var y1 = pos[raw1 + 1];
        var z1 = pos[raw1 + 2];
        var x2 = pos[raw2];
        var y2 = pos[raw2 + 1];
        var z2 = pos[raw2 + 2];

        if (m != null) {
          final tx0 = m[0] * x0 + m[4] * y0 + m[8] * z0 + m[12];
          final ty0 = m[1] * x0 + m[5] * y0 + m[9] * z0 + m[13];
          final tz0 = m[2] * x0 + m[6] * y0 + m[10] * z0 + m[14];
          final tx1 = m[0] * x1 + m[4] * y1 + m[8] * z1 + m[12];
          final ty1 = m[1] * x1 + m[5] * y1 + m[9] * z1 + m[13];
          final tz1 = m[2] * x1 + m[6] * y1 + m[10] * z1 + m[14];
          final tx2 = m[0] * x2 + m[4] * y2 + m[8] * z2 + m[12];
          final ty2 = m[1] * x2 + m[5] * y2 + m[9] * z2 + m[13];
          final tz2 = m[2] * x2 + m[6] * y2 + m[10] * z2 + m[14];
          x0 = tx0;
          y0 = ty0;
          z0 = tz0;
          x1 = tx1;
          y1 = ty1;
          z1 = tz1;
          x2 = tx2;
          y2 = ty2;
          z2 = tz2;
        }

        final e1x = x1 - x0;
        final e1y = y1 - y0;
        final e1z = z1 - z0;
        final e2x = x2 - x0;
        final e2y = y2 - y0;
        final e2z = z2 - z0;
        var nx = e1y * e2z - e1z * e2y;
        var ny = e1z * e2x - e1x * e2z;
        var nz = e1x * e2y - e1y * e2x;
        final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
        if (nLen <= 1e-10) {
          continue;
        }
        nx /= nLen;
        ny /= nLen;
        nz /= nLen;

        // If `transform` had negative determinant (mirror), flip winding so
        // geometric normal stays outward.
        var flipWinding = false;
        if (transform != null && transform.determinant() < 0.0) {
          nx = -nx;
          ny = -ny;
          nz = -nz;
          flipWinding = true;
        }

        final cosSlope = nx * up.x + ny * up.y + nz * up.z;
        if (cosSlope < minCos) {
          continue;
        }

        final w0 = weldVertex(x0, y0, z0);
        final w1 = weldVertex(x1, y1, z1);
        final w2 = weldVertex(x2, y2, z2);
        if (w0 == w1 || w1 == w2 || w2 == w0) {
          continue;
        }

        final i0 = w0;
        final i1 = flipWinding ? w2 : w1;
        final i2 = flipWinding ? w1 : w2;
        final p0 = weldedVerts[i0];
        final p1 = weldedVerts[i1];
        final p2 = weldedVerts[i2];
        final centroid = Vector3(
          (p0.x + p1.x + p2.x) * (1.0 / 3.0),
          (p0.y + p1.y + p2.y) * (1.0 / 3.0),
          (p0.z + p1.z + p2.z) * (1.0 / 3.0),
        );
        rawPolys.add((i0, i1, i2, centroid, Vector3(nx, ny, nz)));
      }
    }

    // Build edge -> polygon adjacency map.
    final edgeMap = <(int, int), List<int>>{};
    for (var pIdx = 0; pIdx < rawPolys.length; pIdx++) {
      final (i0, i1, i2, _, _) = rawPolys[pIdx];
      for (final (ea, eb) in [(i0, i1), (i1, i2), (i2, i0)]) {
        final key = ea < eb ? (ea, eb) : (eb, ea);
        (edgeMap[key] ??= <int>[]).add(pIdx);
      }
    }

    final portalLists = List<List<NavPortal3D>>.generate(
      rawPolys.length,
      (_) => <NavPortal3D>[],
    );

    for (final entry in edgeMap.entries) {
      final (ea, eb) = entry.key;
      final owners = entry.value;
      if (owners.length < 2) {
        continue;
      }
      final va = weldedVerts[ea];
      final vb = weldedVerts[eb];

      for (var i = 0; i < owners.length; i++) {
        final polyA = owners[i];
        final (a0, a1, a2, centA, _) = rawPolys[polyA];
        final oppIdx = (a0 != ea && a0 != eb)
            ? a0
            : ((a1 != ea && a1 != eb) ? a1 : a2);
        final opp = weldedVerts[oppIdx];

        // Orient `(left, right)` from `opp` looking across `(ea, eb)`:
        // `((right - opp) x (left - opp)) . up > 0`.
        final orient = _triArea2Up(opp, va, vb, up);
        final right = orient >= 0.0 ? va : vb;
        final left = orient >= 0.0 ? vb : va;

        for (var j = 0; j < owners.length; j++) {
          if (i == j) {
            continue;
          }
          final polyB = owners[j];
          final (_, _, _, centB, _) = rawPolys[polyB];
          portalLists[polyA].add(
            NavPortal3D(
              targetPoly: polyB,
              left: left,
              right: right,
              cost: centA.distanceTo(centB),
            ),
          );
        }
      }
    }

    final polys = List<NavPoly3D>.generate(rawPolys.length, (idx) {
      final (i0, i1, i2, cent, norm) = rawPolys[idx];
      return NavPoly3D(
        index: idx,
        v0: i0,
        v1: i1,
        v2: i2,
        centroid: cent,
        normal: norm,
        portals: List.unmodifiable(portalLists[idx]),
      );
    }, growable: false);

    return NavMesh3D._(
      vertices: List.unmodifiable(weldedVerts),
      polygons: List.unmodifiable(polys),
      upAxis: up,
    );
  }

  /// Normalized up axis used when classifying walkable slopes and orienting
  /// portals.
  final Vector3 upAxis = upAxis.normalized();

  final Vector3 _basisU = Vector3.zero();
  final Vector3 _basisV = Vector3.zero();
  late final _NavPolyBvh _bvh = _NavPolyBvh.build(vertices, polygons);

  /// Number of walkable triangles in this navmesh.
  int get polyCount => polygons.length;

  /// Clamps an arbitrary 3D [point] onto the closest walkable triangle,
  /// returning `null` when the navmesh has no walkable polygons.
  NavPolyHit3D? findNearestPoly(Vector3 point) {
    if (polygons.isEmpty) {
      return null;
    }
    return _bvh.findNearest(point, vertices, polygons);
  }

  /// Samples the walkable surface elevation (coordinate along [upAxis]) at the
  /// horizontal projection of [pos], picking the layer closest in elevation to
  /// [pos] on multi-level bridges/overpasses, or `null` if [pos] lies outside
  /// all walkable polygons horizontally.
  double? sampleHeightAt(Vector3 pos) {
    if (polygons.isEmpty) {
      return null;
    }
    final targetUp = pos.dot(upAxis);
    final pu = pos.dot(_basisU);
    final pv = pos.dot(_basisV);

    double? bestElevation;
    var bestVerticalDiff = double.infinity;

    for (var i = 0; i < polygons.length; i++) {
      final poly = polygons[i];
      final a = vertices[poly.v0];
      final b = vertices[poly.v1];
      final c = vertices[poly.v2];

      final au = a.dot(_basisU);
      final av = a.dot(_basisV);
      final bu = b.dot(_basisU);
      final bv = b.dot(_basisV);
      final cu = c.dot(_basisU);
      final cv = c.dot(_basisV);

      final v0u = bu - au;
      final v0v = bv - av;
      final v1u = cu - au;
      final v1v = cv - av;
      final denom = v0u * v1v - v1u * v0v;
      if (denom.abs() <= 1e-12) {
        continue;
      }
      final inv = 1.0 / denom;
      final qpu = pu - au;
      final qpv = pv - av;
      final w1 = (qpu * v1v - v1u * qpv) * inv;
      final w2 = (v0u * qpv - qpu * v0v) * inv;
      const tol = -1e-4;
      if (w1 < tol || w2 < tol || w1 + w2 > 1.0 - tol) {
        continue;
      }
      final w0 = 1.0 - w1 - w2;
      final elev = w0 * a.dot(upAxis) + w1 * b.dot(upAxis) + w2 * c.dot(upAxis);
      final diff = (elev - targetUp).abs();
      if (diff < bestVerticalDiff) {
        bestVerticalDiff = diff;
        bestElevation = elev;
      }
    }
    return bestElevation;
  }

  /// Computes the raw A* corridor of polygon centroids between [start] and
  /// [goal] (without funnel string-pulling), returning `[]` if unreachable.
  List<Vector3> findCentroidPath(Vector3 start, Vector3 goal) {
    final sHit = findNearestPoly(start);
    final gHit = findNearestPoly(goal);
    if (sHit == null || gHit == null) {
      return const [];
    }
    final corridor = _astarCorridor(
      sHit.polyIndex,
      gHit.polyIndex,
      gHit.point,
    );
    if (corridor == null) {
      return const [];
    }
    return [
      sHit.point.clone(),
      for (final pIdx in corridor) polygons[pIdx].centroid.clone(),
      gHit.point.clone(),
    ];
  }

  /// Finds the smooth shortest 3D path between [start] and [goal] by clamping
  /// both endpoints onto the navmesh, running A* over polygon portals, and
  /// string-pulling via the **3D Simple Stupid Funnel** algorithm with
  /// portal-edge elevation draping across ramps and bridges.
  ///
  /// Returns an empty list if no connected path exists.
  List<Vector3> findPath(Vector3 start, Vector3 goal) {
    final sHit = findNearestPoly(start);
    final gHit = findNearestPoly(goal);
    if (sHit == null || gHit == null) {
      return const [];
    }
    if (sHit.polyIndex == gHit.polyIndex) {
      if (sHit.point.distanceToSquared(gHit.point) <= 1e-12) {
        return [sHit.point.clone()];
      }
      return [sHit.point.clone(), gHit.point.clone()];
    }

    final corridor = _astarCorridor(
      sHit.polyIndex,
      gHit.polyIndex,
      gHit.point,
    );
    if (corridor == null) {
      return const [];
    }

    // Build portal sequence `portals[0 .. k]` where `portals[0..k-1]` are the
    // shared edges along `corridor` and `portals[k]` collapses to `gHit.point`.
    final portalsLeft = <Vector3>[sHit.point];
    final portalsRight = <Vector3>[sHit.point];

    for (var i = 0; i < corridor.length - 1; i++) {
      final curr = polygons[corridor[i]];
      final nextIdx = corridor[i + 1];
      NavPortal3D? portal;
      for (var p = 0; p < curr.portals.length; p++) {
        if (curr.portals[p].targetPoly == nextIdx) {
          portal = curr.portals[p];
          break;
        }
      }
      if (portal == null) {
        return const [];
      }
      portalsLeft.add(portal.left);
      portalsRight.add(portal.right);
    }
    portalsLeft.add(gHit.point);
    portalsRight.add(gHit.point);

    // 3D Simple Stupid Funnel (in horizontal plane perpendicular to `upAxis`),
    // recording which portal index produced each corner so we can drape over
    // 3D ramp/bridge creases between consecutive corners!
    final cornerPoints = <Vector3>[sHit.point.clone()];
    final cornerPortalIndices = <int>[0];

    var apex = sHit.point;
    var portalLeft = sHit.point;
    var portalRight = sHit.point;
    var apexIndex = 0;
    var leftIndex = 0;
    var rightIndex = 0;

    for (var i = 1; i < portalsLeft.length; i++) {
      final left = portalsLeft[i];
      final right = portalsRight[i];

      // 1. Update right side of funnel (`triArea2(apex, portalRight, right)`).
      if (_triArea2Horiz(apex, portalRight, right) >= 0.0) {
        if (_horizDist2(apex, portalRight) <= 1e-12 ||
            _triArea2Horiz(apex, portalLeft, right) < 0.0) {
          portalRight = right;
          rightIndex = i;
        } else {
          // `right` crossed over `portalLeft`: `portalLeft` is a taut corner!
          if (_horizDist2(cornerPoints.last, portalLeft) > 1e-10) {
            cornerPoints.add(portalLeft.clone());
            cornerPortalIndices.add(leftIndex);
          }
          apex = portalLeft;
          apexIndex = leftIndex;
          portalLeft = apex;
          portalRight = apex;
          leftIndex = apexIndex;
          rightIndex = apexIndex;
          i = apexIndex;
          continue;
        }
      }

      // 2. Update left side of funnel (`triArea2(apex, portalLeft, left)`).
      if (_triArea2Horiz(apex, portalLeft, left) <= 0.0) {
        if (_horizDist2(apex, portalLeft) <= 1e-12 ||
            _triArea2Horiz(apex, portalRight, left) > 0.0) {
          portalLeft = left;
          leftIndex = i;
        } else {
          // `left` crossed over `portalRight`: `portalRight` is a taut corner!
          if (_horizDist2(cornerPoints.last, portalRight) > 1e-10) {
            cornerPoints.add(portalRight.clone());
            cornerPortalIndices.add(rightIndex);
          }
          apex = portalRight;
          apexIndex = rightIndex;
          portalLeft = apex;
          portalRight = apex;
          leftIndex = apexIndex;
          rightIndex = apexIndex;
          i = apexIndex;
          continue;
        }
      }
    }

    if (cornerPoints.last.distanceToSquared(gHit.point) > 1e-10) {
      cornerPoints.add(gHit.point.clone());
      cornerPortalIndices.add(portalsLeft.length - 1);
    } else {
      cornerPoints[cornerPoints.length - 1] = gHit.point.clone();
      cornerPortalIndices[cornerPortalIndices.length - 1] =
          portalsLeft.length - 1;
    }

    // Drape each horizontal funnel span across intermediate portals where 3D
    // elevation changes (ramps/bridges), preserving zero extra points on flat
    // spans!
    final smoothWaypoints = <Vector3>[cornerPoints.first];
    for (var s = 0; s < cornerPoints.length - 1; s++) {
      final wpA = cornerPoints[s];
      final wpB = cornerPoints[s + 1];
      final pStart = math.min(
        cornerPortalIndices[s],
        cornerPortalIndices[s + 1],
      );
      final pEnd = math.max(
        cornerPortalIndices[s],
        cornerPortalIndices[s + 1],
      );
      _drapeSegmentAcrossPortals(
        wpA,
        wpB,
        pStart,
        pEnd,
        portalsLeft,
        portalsRight,
        smoothWaypoints,
      );
      smoothWaypoints.add(wpB);
    }

    return smoothWaypoints;
  }

  void _drapeSegmentAcrossPortals(
    Vector3 wpA,
    Vector3 wpB,
    int pStart,
    int pEnd,
    List<Vector3> portalsLeft,
    List<Vector3> portalsRight,
    List<Vector3> out,
  ) {
    if (pEnd - pStart <= 1) {
      return;
    }
    final au = wpA.dot(_basisU);
    final av = wpA.dot(_basisV);
    final bu = wpB.dot(_basisU);
    final bv = wpB.dot(_basisV);
    final du = bu - au;
    final dv = bv - av;
    final segLen2 = du * du + dv * dv;
    if (segLen2 <= 1e-10) {
      return;
    }

    var bestDev = 1e-3;
    Vector3? splitPoint;
    var splitPortal = -1;

    final aUp = wpA.dot(upAxis);
    final bUp = wpB.dot(upAxis);

    for (var p = pStart + 1; p < pEnd; p++) {
      final l = portalsLeft[p];
      final r = portalsRight[p];
      final lu = l.dot(_basisU);
      final lv = l.dot(_basisV);
      final eu = r.dot(_basisU) - lu;
      final ev = r.dot(_basisV) - lv;

      // 2D segment intersection `(au,av) + t*(du,dv) == (lu,lv) + s*(eu,ev)`.
      final denom = du * ev - dv * eu;
      if (denom.abs() <= 1e-10) {
        continue;
      }
      final inv = 1.0 / denom;
      final qx = lu - au;
      final qy = lv - av;
      final t = (qx * ev - qy * eu) * inv;
      final s = ((qx * dv - qy * du) * inv).clamp(0.0, 1.0);
      if (t <= 1e-3 || t >= 1.0 - 1e-3) {
        continue;
      }

      final crossPt = Vector3(
        l.x + (r.x - l.x) * s,
        l.y + (r.y - l.y) * s,
        l.z + (r.z - l.z) * s,
      );
      final chordUp = aUp + (bUp - aUp) * t;
      final dev = (crossPt.dot(upAxis) - chordUp).abs();
      if (dev > bestDev) {
        bestDev = dev;
        splitPoint = crossPt;
        splitPortal = p;
      }
    }

    if (splitPoint != null && splitPortal > pStart && splitPortal < pEnd) {
      _drapeSegmentAcrossPortals(
        wpA,
        splitPoint,
        pStart,
        splitPortal,
        portalsLeft,
        portalsRight,
        out,
      );
      out.add(splitPoint);
      _drapeSegmentAcrossPortals(
        splitPoint,
        wpB,
        splitPortal,
        pEnd,
        portalsLeft,
        portalsRight,
        out,
      );
    }
  }

  List<int>? _astarCorridor(int startPoly, int goalPoly, Vector3 goalPoint) {
    final n = polygons.length;
    final gScore = Float64List(n)..fillRange(0, n, double.infinity);
    final cameFrom = Int32List(n)..fillRange(0, n, -1);
    final closed = Uint8List(n);
    final heap = _MinPolyHeap(n);

    gScore[startPoly] = 0.0;
    heap.push(startPoly, polygons[startPoly].centroid.distanceTo(goalPoint));

    while (!heap.isEmpty) {
      final current = heap.pop();
      if (current == goalPoly) {
        final path = <int>[];
        var curr = goalPoly;
        while (curr != -1) {
          path.add(curr);
          curr = cameFrom[curr];
        }
        return path.reversed.toList(growable: false);
      }
      if (closed[current] != 0) {
        continue;
      }
      closed[current] = 1;

      final portals = polygons[current].portals;
      final curG = gScore[current];
      for (var i = 0; i < portals.length; i++) {
        final portal = portals[i];
        final next = portal.targetPoly;
        if (closed[next] != 0) {
          continue;
        }
        final tentativeG = curG + portal.cost;
        if (tentativeG < gScore[next]) {
          gScore[next] = tentativeG;
          cameFrom[next] = current;
          final f = tentativeG + polygons[next].centroid.distanceTo(goalPoint);
          heap.pushOrDecrease(next, f);
        }
      }
    }
    return null;
  }

  double _horizDist2(Vector3 a, Vector3 b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final dz = b.z - a.z;
    final du = dx * _basisU.x + dy * _basisU.y + dz * _basisU.z;
    final dv = dx * _basisV.x + dy * _basisV.y + dz * _basisV.z;
    return du * du + dv * dv;
  }

  double _triArea2Horiz(Vector3 a, Vector3 b, Vector3 c) {
    return _triArea2Up(a, b, c, upAxis);
  }

  static double _triArea2Up(Vector3 a, Vector3 b, Vector3 c, Vector3 up) {
    final abx = b.x - a.x;
    final aby = b.y - a.y;
    final abz = b.z - a.z;
    final acx = c.x - a.x;
    final acy = c.y - a.y;
    final acz = c.z - a.z;
    final cx = aby * acz - abz * acy;
    final cy = abz * acx - abx * acz;
    final cz = abx * acy - aby * acx;
    return cx * up.x + cy * up.y + cz * up.z;
  }
}

class _MinPolyHeap(int maxPolys) {
  final Int32List _nodes = Int32List(maxPolys + 1);
  final Float64List _priorities = Float64List(maxPolys + 1);
  final Int32List _heapPos = Int32List(maxPolys)..fillRange(0, maxPolys, -1);
  int _size = 0;

  bool get isEmpty => _size == 0;

  void push(int poly, double f) {
    final idx = _size++;
    _nodes[idx] = poly;
    _priorities[idx] = f;
    _heapPos[poly] = idx;
    _siftUp(idx);
  }

  void pushOrDecrease(int poly, double f) {
    final existing = _heapPos[poly];
    if (existing >= 0) {
      if (f < _priorities[existing]) {
        _priorities[existing] = f;
        _siftUp(existing);
      }
      return;
    }
    push(poly, f);
  }

  int pop() {
    final top = _nodes[0];
    _heapPos[top] = -1;
    _size--;
    if (_size > 0) {
      _nodes[0] = _nodes[_size];
      _priorities[0] = _priorities[_size];
      _heapPos[_nodes[0]] = 0;
      _siftDown(0);
    }
    return top;
  }

  void _siftUp(int index) {
    var i = index;
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_priorities[i] >= _priorities[parent]) {
        break;
      }
      _swap(i, parent);
      i = parent;
    }
  }

  void _siftDown(int index) {
    var i = index;
    while (true) {
      final left = (i << 1) + 1;
      if (left >= _size) {
        break;
      }
      var smallest = left;
      final right = left + 1;
      if (right < _size && _priorities[right] < _priorities[left]) {
        smallest = right;
      }
      if (_priorities[i] <= _priorities[smallest]) {
        break;
      }
      _swap(i, smallest);
      i = smallest;
    }
  }

  void _swap(int a, int b) {
    final na = _nodes[a];
    final nb = _nodes[b];
    final pa = _priorities[a];
    _nodes[a] = nb;
    _nodes[b] = na;
    _priorities[a] = _priorities[b];
    _priorities[b] = pa;
    _heapPos[nb] = a;
    _heapPos[na] = b;
  }
}

class _NavPolyBvh._({
  required final int nodeCount,
  required final Float32List bounds,
  required final Int32List leftOrFirst,
  required final Int32List rightChild,
  required final Int32List counts,
  required final Int32List polyIndices,
}) {
  factory _NavPolyBvh.build(List<Vector3> verts, List<NavPoly3D> polys) {
    final n = polys.length;
    if (n == 0) {
      return _NavPolyBvh._(
        nodeCount: 0,
        bounds: Float32List(0),
        leftOrFirst: Int32List(0),
        rightChild: Int32List(0),
        counts: Int32List(0),
        polyIndices: Int32List(0),
      );
    }

    final indices = Int32List(n);
    final triBounds = Float32List(n * 6);
    for (var i = 0; i < n; i++) {
      indices[i] = i;
      final p = polys[i];
      final v0 = verts[p.v0];
      final v1 = verts[p.v1];
      final v2 = verts[p.v2];
      final tb = i * 6;
      triBounds
        ..[tb] = math.min(v0.x, math.min(v1.x, v2.x))
        ..[tb + 1] = math.min(v0.y, math.min(v1.y, v2.y))
        ..[tb + 2] = math.min(v0.z, math.min(v1.z, v2.z))
        ..[tb + 3] = math.max(v0.x, math.max(v1.x, v2.x))
        ..[tb + 4] = math.max(v0.y, math.max(v1.y, v2.y))
        ..[tb + 5] = math.max(v0.z, math.max(v1.z, v2.z));
    }

    final maxNodes = math.max(1, n * 2);
    final bounds = Float32List(maxNodes * 6);
    final leftOrFirst = Int32List(maxNodes);
    final rightChild = Int32List(maxNodes);
    final counts = Int32List(maxNodes);
    var nodeCount = 0;

    int build(int start, int count) {
      final node = nodeCount++;
      var minX = double.infinity;
      var minY = double.infinity;
      var minZ = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;
      var maxZ = double.negativeInfinity;
      var cMinX = double.infinity;
      var cMinY = double.infinity;
      var cMinZ = double.infinity;
      var cMaxX = double.negativeInfinity;
      var cMaxY = double.negativeInfinity;
      var cMaxZ = double.negativeInfinity;

      for (var i = start; i < start + count; i++) {
        final pIdx = indices[i];
        final tb = pIdx * 6;
        minX = math.min(minX, triBounds[tb]);
        minY = math.min(minY, triBounds[tb + 1]);
        minZ = math.min(minZ, triBounds[tb + 2]);
        maxX = math.max(maxX, triBounds[tb + 3]);
        maxY = math.max(maxY, triBounds[tb + 4]);
        maxZ = math.max(maxZ, triBounds[tb + 5]);

        final c = polys[pIdx].centroid;
        cMinX = math.min(cMinX, c.x);
        cMinY = math.min(cMinY, c.y);
        cMinZ = math.min(cMinZ, c.z);
        cMaxX = math.max(cMaxX, c.x);
        cMaxY = math.max(cMaxY, c.y);
        cMaxZ = math.max(cMaxZ, c.z);
      }

      final nb = node * 6;
      bounds
        ..[nb] = minX
        ..[nb + 1] = minY
        ..[nb + 2] = minZ
        ..[nb + 3] = maxX
        ..[nb + 4] = maxY
        ..[nb + 5] = maxZ;

      if (count <= 4) {
        leftOrFirst[node] = start;
        counts[node] = count;
        return node;
      }

      var axis = 0;
      var split = 0.5 * (cMinX + cMaxX);
      var ext = cMaxX - cMinX;
      if (cMaxY - cMinY > ext) {
        axis = 1;
        split = 0.5 * (cMinY + cMaxY);
        ext = cMaxY - cMinY;
      }
      if (cMaxZ - cMinZ > ext) {
        axis = 2;
        split = 0.5 * (cMinZ + cMaxZ);
        ext = cMaxZ - cMinZ;
      }

      int mid;
      if (ext <= 1e-12) {
        mid = start + (count >> 1);
      } else {
        var i = start;
        var j = start + count - 1;
        while (i <= j) {
          final c = polys[indices[i]].centroid;
          final val = axis == 0 ? c.x : (axis == 1 ? c.y : c.z);
          if (val < split) {
            i++;
          } else {
            final tmp = indices[i];
            indices[i] = indices[j];
            indices[j] = tmp;
            j--;
          }
        }
        mid = i;
        if (mid == start || mid == start + count) {
          mid = start + (count >> 1);
        }
      }

      counts[node] = 0;
      leftOrFirst[node] = build(start, mid - start);
      rightChild[node] = build(mid, start + count - mid);
      return node;
    }

    build(0, n);
    return _NavPolyBvh._(
      nodeCount: nodeCount,
      bounds: Float32List.sublistView(bounds, 0, nodeCount * 6),
      leftOrFirst: Int32List.sublistView(leftOrFirst, 0, nodeCount),
      rightChild: Int32List.sublistView(rightChild, 0, nodeCount),
      counts: Int32List.sublistView(counts, 0, nodeCount),
      polyIndices: indices,
    );
  }

  final Int32List _stack = Int32List(128);
  final Vector3 _cand = Vector3.zero();

  NavPolyHit3D? findNearest(
    Vector3 query,
    List<Vector3> verts,
    List<NavPoly3D> polys,
  ) {
    if (nodeCount == 0) {
      return null;
    }
    final qx = query.x;
    final qy = query.y;
    final qz = query.z;

    var bestPoly = -1;
    var bestD2 = double.infinity;
    final bestPt = Vector3.zero();

    var sp = 0;
    _stack[sp++] = 0;

    while (sp > 0) {
      final node = _stack[--sp];
      if (_boxDist2(node, qx, qy, qz) >= bestD2) {
        continue;
      }
      final cnt = counts[node];
      if (cnt > 0) {
        final start = leftOrFirst[node];
        for (var i = start; i < start + cnt; i++) {
          final pIdx = polyIndices[i];
          final poly = polys[pIdx];
          _closestPointOnTri(
            qx,
            qy,
            qz,
            verts[poly.v0],
            verts[poly.v1],
            verts[poly.v2],
            _cand,
          );
          final dx = _cand.x - qx;
          final dy = _cand.y - qy;
          final dz = _cand.z - qz;
          final d2 = dx * dx + dy * dy + dz * dz;
          if (d2 < bestD2) {
            bestD2 = d2;
            bestPoly = pIdx;
            bestPt.setFrom(_cand);
          }
        }
      } else {
        final left = leftOrFirst[node];
        final right = rightChild[node];
        final dL = _boxDist2(left, qx, qy, qz);
        final dR = _boxDist2(right, qx, qy, qz);
        if (dL < dR) {
          if (dR < bestD2) {
            _stack[sp++] = right;
          }
          if (dL < bestD2) {
            _stack[sp++] = left;
          }
        } else {
          if (dL < bestD2) {
            _stack[sp++] = left;
          }
          if (dR < bestD2) {
            _stack[sp++] = right;
          }
        }
      }
    }

    if (bestPoly < 0) {
      return null;
    }
    return NavPolyHit3D(
      polyIndex: bestPoly,
      point: bestPt,
      distanceSquared: bestD2,
    );
  }

  double _boxDist2(int node, double qx, double qy, double qz) {
    final nb = node * 6;
    final minX = bounds[nb];
    final minY = bounds[nb + 1];
    final minZ = bounds[nb + 2];
    final maxX = bounds[nb + 3];
    final maxY = bounds[nb + 4];
    final maxZ = bounds[nb + 5];
    final dx = qx < minX ? minX - qx : (qx > maxX ? qx - maxX : 0.0);
    final dy = qy < minY ? minY - qy : (qy > maxY ? qy - maxY : 0.0);
    final dz = qz < minZ ? minZ - qz : (qz > maxZ ? qz - maxZ : 0.0);
    return dx * dx + dy * dy + dz * dz;
  }

  static void _closestPointOnTri(
    double px,
    double py,
    double pz,
    Vector3 a,
    Vector3 b,
    Vector3 c,
    Vector3 out,
  ) {
    final abx = b.x - a.x;
    final aby = b.y - a.y;
    final abz = b.z - a.z;
    final acx = c.x - a.x;
    final acy = c.y - a.y;
    final acz = c.z - a.z;
    final apx = px - a.x;
    final apy = py - a.y;
    final apz = pz - a.z;

    final d1 = abx * apx + aby * apy + abz * apz;
    final d2 = acx * apx + acy * apy + acz * apz;
    if (d1 <= 0.0 && d2 <= 0.0) {
      out.setFrom(a);
      return;
    }

    final bpx = px - b.x;
    final bpy = py - b.y;
    final bpz = pz - b.z;
    final d3 = abx * bpx + aby * bpy + abz * bpz;
    final d4 = acx * bpx + acy * bpy + acz * bpz;
    if (d3 >= 0.0 && d4 <= d3) {
      out.setFrom(b);
      return;
    }

    final vc = d1 * d4 - d3 * d2;
    if (vc <= 0.0 && d1 >= 0.0 && d3 <= 0.0) {
      final v = d1 / (d1 - d3);
      out.setValues(a.x + v * abx, a.y + v * aby, a.z + v * abz);
      return;
    }

    final cpx = px - c.x;
    final cpy = py - c.y;
    final cpz = pz - c.z;
    final d5 = abx * cpx + aby * cpy + abz * cpz;
    final d6 = acx * cpx + acy * cpy + acz * cpz;
    if (d6 >= 0.0 && d5 <= d6) {
      out.setFrom(c);
      return;
    }

    final vb = d5 * d2 - d1 * d6;
    if (vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0) {
      final w = d2 / (d2 - d6);
      out.setValues(a.x + w * acx, a.y + w * acy, a.z + w * acz);
      return;
    }

    final va = d3 * d6 - d5 * d4;
    if (va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0) {
      final w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
      out.setValues(
        b.x + w * (c.x - b.x),
        b.y + w * (c.y - b.y),
        b.z + w * (c.z - b.z),
      );
      return;
    }

    final denom = 1.0 / (va + vb + vc);
    final v = vb * denom;
    final w = vc * denom;
    out.setValues(
      a.x + abx * v + acx * w,
      a.y + aby * v + acy * w,
      a.z + abz * v + acz * w,
    );
  }
}
