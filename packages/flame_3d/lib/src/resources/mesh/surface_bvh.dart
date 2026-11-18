import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/camera.dart' show Ray;
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template surface_ray_hit}
/// A narrowphase ray intersection on a [Surface] in the surface's local space.
/// {@endtemplate}
class SurfaceRayHit({
  /// Distance along the local ray from its origin (`origin + direction * t`).
  required final double distance,

  /// Hit point in surface local space.
  required final Vector3 point,

  /// Geometric face normal at the hit point in surface local space (unit
  /// length, oriented counter-clockwise `(v1 - v0) x (v2 - v0)`).
  required final Vector3 normal,

  /// First barycentric coordinate on edge `v1 - v0`.
  required final double barycentricU,

  /// Second barycentric coordinate on edge `v2 - v0`.
  required final double barycentricV,

  /// Zero-based triangle index (`indices[triangleIndex * 3 .. +2]`).
  required final int triangleIndex,
});

/// {@template surface_bvh}
/// Zero-allocation flat median-split Bounding Volume Hierarchy over the
/// triangles of a [Surface] for `O(log T)` ray-mesh queries.
///
/// Node bounds and child/leaf indices live in contiguous [Float32List] and
/// [Int32List] buffers, and ray traversal uses a fixed iterative stack with
/// nearest-child-first ordering so occluded subtrees are pruned early.
/// {@endtemplate}
class SurfaceBvh {
  /// Builds a BVH for [surface]. Prefer reading `surface.bvh`, which caches
  /// the hierarchy lazily on the surface.
  factory SurfaceBvh.build(Surface surface, {int maxLeafTriangles = 4}) {
    if (maxLeafTriangles < 1) {
      throw ArgumentError.value(
        maxLeafTriangles,
        'maxLeafTriangles',
        'Must be at least 1',
      );
    }
    final posOffset = surface.layout.offsetOf(VertexLayout.positionAttribute);
    if (posOffset == null) {
      return SurfaceBvh._empty(surface);
    }
    final indices = surface.indices;
    final triCount = indices.length ~/ 3;
    if (triCount == 0) {
      return SurfaceBvh._empty(surface);
    }

    final verts = surface.vertexData;
    final stride = surface.layout.strideInFloats;
    final triIndices = Int32List(triCount);
    final triBounds = Float32List(triCount * 6);
    final centroids = Float32List(triCount * 3);

    for (var t = 0; t < triCount; t++) {
      triIndices[t] = t;
      final b = t * 3;
      final i0 = indices[b] * stride + posOffset;
      final i1 = indices[b + 1] * stride + posOffset;
      final i2 = indices[b + 2] * stride + posOffset;

      final x0 = verts[i0];
      final y0 = verts[i0 + 1];
      final z0 = verts[i0 + 2];
      final x1 = verts[i1];
      final y1 = verts[i1 + 1];
      final z1 = verts[i1 + 2];
      final x2 = verts[i2];
      final y2 = verts[i2 + 1];
      final z2 = verts[i2 + 2];

      final minX = math.min(x0, math.min(x1, x2));
      final minY = math.min(y0, math.min(y1, y2));
      final minZ = math.min(z0, math.min(z1, z2));
      final maxX = math.max(x0, math.max(x1, x2));
      final maxY = math.max(y0, math.max(y1, y2));
      final maxZ = math.max(z0, math.max(z1, z2));

      final tb = t * 6;
      triBounds
        ..[tb] = minX
        ..[tb + 1] = minY
        ..[tb + 2] = minZ
        ..[tb + 3] = maxX
        ..[tb + 4] = maxY
        ..[tb + 5] = maxZ;

      final cb = t * 3;
      centroids
        ..[cb] = (x0 + x1 + x2) * (1.0 / 3.0)
        ..[cb + 1] = (y0 + y1 + y2) * (1.0 / 3.0)
        ..[cb + 2] = (z0 + z1 + z2) * (1.0 / 3.0);
    }

    final maxNodes = math.max(1, triCount * 2);
    final bounds = Float32List(maxNodes * 6);
    final leftOrFirst = Int32List(maxNodes);
    final rightChild = Int32List(maxNodes);
    final counts = Int32List(maxNodes);
    var nodeCount = 0;

    int buildNode(int start, int count) {
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
        final t = triIndices[i];
        final tb = t * 6;
        minX = math.min(minX, triBounds[tb]);
        minY = math.min(minY, triBounds[tb + 1]);
        minZ = math.min(minZ, triBounds[tb + 2]);
        maxX = math.max(maxX, triBounds[tb + 3]);
        maxY = math.max(maxY, triBounds[tb + 4]);
        maxZ = math.max(maxZ, triBounds[tb + 5]);

        final cb = t * 3;
        final cx = centroids[cb];
        final cy = centroids[cb + 1];
        final cz = centroids[cb + 2];
        cMinX = math.min(cMinX, cx);
        cMinY = math.min(cMinY, cy);
        cMinZ = math.min(cMinZ, cz);
        cMaxX = math.max(cMaxX, cx);
        cMaxY = math.max(cMaxY, cy);
        cMaxZ = math.max(cMaxZ, cz);
      }

      final nb = node * 6;
      bounds
        ..[nb] = minX
        ..[nb + 1] = minY
        ..[nb + 2] = minZ
        ..[nb + 3] = maxX
        ..[nb + 4] = maxY
        ..[nb + 5] = maxZ;

      if (count <= maxLeafTriangles) {
        leftOrFirst[node] = start;
        counts[node] = count;
        return node;
      }

      final extX = cMaxX - cMinX;
      final extY = cMaxY - cMinY;
      final extZ = cMaxZ - cMinZ;
      var axis = 0;
      var split = 0.5 * (cMinX + cMaxX);
      var extent = extX;
      if (extY > extent) {
        axis = 1;
        split = 0.5 * (cMinY + cMaxY);
        extent = extY;
      }
      if (extZ > extent) {
        axis = 2;
        split = 0.5 * (cMinZ + cMaxZ);
        extent = extZ;
      }

      int mid;
      if (extent <= 1e-12) {
        mid = start + (count >> 1);
      } else {
        var i = start;
        var j = start + count - 1;
        while (i <= j) {
          if (centroids[triIndices[i] * 3 + axis] < split) {
            i++;
          } else {
            final tmp = triIndices[i];
            triIndices[i] = triIndices[j];
            triIndices[j] = tmp;
            j--;
          }
        }
        mid = i;
        if (mid == start || mid == start + count) {
          mid = start + (count >> 1);
        }
      }

      counts[node] = 0;
      leftOrFirst[node] = buildNode(start, mid - start);
      rightChild[node] = buildNode(mid, start + count - mid);
      return node;
    }

    buildNode(0, triCount);

    return SurfaceBvh._(
      surface: surface,
      positionOffset: posOffset,
      stride: stride,
      nodeCount: nodeCount,
      triangleCount: triCount,
      bounds: Float32List.sublistView(bounds, 0, nodeCount * 6),
      leftOrFirst: Int32List.sublistView(leftOrFirst, 0, nodeCount),
      rightChild: Int32List.sublistView(rightChild, 0, nodeCount),
      counts: Int32List.sublistView(counts, 0, nodeCount),
      triangles: triIndices,
    );
  }

  SurfaceBvh._({
    required this.surface,
    required this._positionOffset,
    required this._stride,
    required this.nodeCount,
    required this.triangleCount,
    required this._bounds,
    required this._leftOrFirst,
    required this._rightChild,
    required this._counts,
    required this._triangles,
  });

  SurfaceBvh._empty(this.surface)
    : _positionOffset = 0,
      _stride = 0,
      nodeCount = 0,
      triangleCount = 0,
      _bounds = Float32List(0),
      _leftOrFirst = Int32List(0),
      _rightChild = Int32List(0),
      _counts = Int32List(0),
      _triangles = Int32List(0);

  /// The surface indexed by this BVH.
  final Surface surface;

  /// Number of BVH nodes (`0` when the surface has no triangles).
  final int nodeCount;

  /// Number of indexed triangles in [surface].
  final int triangleCount;

  final int _positionOffset;
  final int _stride;
  final Float32List _bounds;
  final Int32List _leftOrFirst;
  final Int32List _rightChild;
  final Int32List _counts;
  final Int32List _triangles;

  final Int32List _stack = Int32List(128);

  /// Finds the closest intersection of [ray] (in [surface]'s local space)
  /// within `[0, maxDistance]`, or `null` when nothing is hit.
  ///
  /// [cullMode] controls whether back-facing (`det < 0`) or front-facing
  /// (`det > 0`) triangles are ignored; defaults to [CullMode.none] (both
  /// sides hit).
  SurfaceRayHit? raycast(
    Ray ray, {
    double maxDistance = double.infinity,
    CullMode cullMode = CullMode.none,
  }) {
    if (nodeCount == 0 || maxDistance <= 0) {
      return null;
    }
    final ox = ray.origin.x;
    final oy = ray.origin.y;
    final oz = ray.origin.z;
    final dx = ray.direction.x;
    final dy = ray.direction.y;
    final dz = ray.direction.z;

    if (_rayBoxEntry(0, ox, oy, oz, dx, dy, dz, maxDistance) ==
        double.infinity) {
      return null;
    }

    final verts = surface.vertexData;
    final indices = surface.indices;
    final stride = _stride;
    final posOffset = _positionOffset;

    var bestT = maxDistance;
    var bestU = 0.0;
    var bestV = 0.0;
    var bestTri = -1;
    var bestNx = 0.0;
    var bestNy = 0.0;
    var bestNz = 1.0;

    var sp = 0;
    _stack[sp++] = 0;

    while (sp > 0) {
      final node = _stack[--sp];
      if (_rayBoxEntry(node, ox, oy, oz, dx, dy, dz, bestT) ==
          double.infinity) {
        continue;
      }

      final count = _counts[node];
      if (count > 0) {
        final start = _leftOrFirst[node];
        for (var i = start; i < start + count; i++) {
          final tri = _triangles[i];
          final b = tri * 3;
          final i0 = indices[b] * stride + posOffset;
          final i1 = indices[b + 1] * stride + posOffset;
          final i2 = indices[b + 2] * stride + posOffset;

          final v0x = verts[i0];
          final v0y = verts[i0 + 1];
          final v0z = verts[i0 + 2];
          final e1x = verts[i1] - v0x;
          final e1y = verts[i1 + 1] - v0y;
          final e1z = verts[i1 + 2] - v0z;
          final e2x = verts[i2] - v0x;
          final e2y = verts[i2 + 1] - v0y;
          final e2z = verts[i2 + 2] - v0z;

          final hx = dy * e2z - dz * e2y;
          final hy = dz * e2x - dx * e2z;
          final hz = dx * e2y - dy * e2x;
          final det = e1x * hx + e1y * hy + e1z * hz;

          switch (cullMode) {
            case CullMode.none:
              if (det.abs() < 1e-12) {
                continue;
              }
            case CullMode.backFace:
              if (det < 1e-12) {
                continue;
              }
            case CullMode.frontFace:
              if (det > -1e-12) {
                continue;
              }
          }

          final invDet = 1.0 / det;
          final sx = ox - v0x;
          final sy = oy - v0y;
          final sz = oz - v0z;
          final u = (sx * hx + sy * hy + sz * hz) * invDet;
          if (u < -1e-6 || u > 1.0 + 1e-6) {
            continue;
          }

          final qx = sy * e1z - sz * e1y;
          final qy = sz * e1x - sx * e1z;
          final qz = sx * e1y - sy * e1x;
          final v = (dx * qx + dy * qy + dz * qz) * invDet;
          if (v < -1e-6 || u + v > 1.0 + 1e-6) {
            continue;
          }

          final t = (e2x * qx + e2y * qy + e2z * qz) * invDet;
          if (t > 1e-7 && t < bestT) {
            bestT = t;
            bestU = u;
            bestV = v;
            bestTri = tri;
            bestNx = e1y * e2z - e1z * e2y;
            bestNy = e1z * e2x - e1x * e2z;
            bestNz = e1x * e2y - e1y * e2x;
          }
        }
      } else {
        final left = _leftOrFirst[node];
        final right = _rightChild[node];
        final tLeft = _rayBoxEntry(left, ox, oy, oz, dx, dy, dz, bestT);
        final tRight = _rayBoxEntry(right, ox, oy, oz, dx, dy, dz, bestT);
        if (tLeft < tRight) {
          if (tRight < bestT) {
            _stack[sp++] = right;
          }
          if (tLeft < bestT) {
            _stack[sp++] = left;
          }
        } else {
          if (tLeft < bestT) {
            _stack[sp++] = left;
          }
          if (tRight < bestT) {
            _stack[sp++] = right;
          }
        }
      }
    }

    if (bestTri < 0) {
      return null;
    }
    final nLen = math.sqrt(bestNx * bestNx + bestNy * bestNy + bestNz * bestNz);
    final invLen = nLen > 1e-12 ? 1.0 / nLen : 0.0;
    return SurfaceRayHit(
      distance: bestT,
      point: Vector3(ox + dx * bestT, oy + dy * bestT, oz + dz * bestT),
      normal: Vector3(bestNx * invLen, bestNy * invLen, bestNz * invLen),
      barycentricU: bestU,
      barycentricV: bestV,
      triangleIndex: bestTri,
    );
  }

  /// Appends all intersections of [ray] within `[0, maxDistance]` into [out].
  void raycastAll(
    Ray ray,
    List<SurfaceRayHit> out, {
    double maxDistance = double.infinity,
    CullMode cullMode = CullMode.none,
  }) {
    if (nodeCount == 0 || maxDistance <= 0) {
      return;
    }
    final ox = ray.origin.x;
    final oy = ray.origin.y;
    final oz = ray.origin.z;
    final dx = ray.direction.x;
    final dy = ray.direction.y;
    final dz = ray.direction.z;

    if (_rayBoxEntry(0, ox, oy, oz, dx, dy, dz, maxDistance) ==
        double.infinity) {
      return;
    }

    final verts = surface.vertexData;
    final indices = surface.indices;
    final stride = _stride;
    final posOffset = _positionOffset;

    var sp = 0;
    _stack[sp++] = 0;

    while (sp > 0) {
      final node = _stack[--sp];
      if (_rayBoxEntry(node, ox, oy, oz, dx, dy, dz, maxDistance) ==
          double.infinity) {
        continue;
      }

      final count = _counts[node];
      if (count > 0) {
        final start = _leftOrFirst[node];
        for (var i = start; i < start + count; i++) {
          final tri = _triangles[i];
          final b = tri * 3;
          final i0 = indices[b] * stride + posOffset;
          final i1 = indices[b + 1] * stride + posOffset;
          final i2 = indices[b + 2] * stride + posOffset;

          final v0x = verts[i0];
          final v0y = verts[i0 + 1];
          final v0z = verts[i0 + 2];
          final e1x = verts[i1] - v0x;
          final e1y = verts[i1 + 1] - v0y;
          final e1z = verts[i1 + 2] - v0z;
          final e2x = verts[i2] - v0x;
          final e2y = verts[i2 + 1] - v0y;
          final e2z = verts[i2 + 2] - v0z;

          final hx = dy * e2z - dz * e2y;
          final hy = dz * e2x - dx * e2z;
          final hz = dx * e2y - dy * e2x;
          final det = e1x * hx + e1y * hy + e1z * hz;

          switch (cullMode) {
            case CullMode.none:
              if (det.abs() < 1e-12) {
                continue;
              }
            case CullMode.backFace:
              if (det < 1e-12) {
                continue;
              }
            case CullMode.frontFace:
              if (det > -1e-12) {
                continue;
              }
          }

          final invDet = 1.0 / det;
          final sx = ox - v0x;
          final sy = oy - v0y;
          final sz = oz - v0z;
          final u = (sx * hx + sy * hy + sz * hz) * invDet;
          if (u < -1e-6 || u > 1.0 + 1e-6) {
            continue;
          }

          final qx = sy * e1z - sz * e1y;
          final qy = sz * e1x - sx * e1z;
          final qz = sx * e1y - sy * e1x;
          final v = (dx * qx + dy * qy + dz * qz) * invDet;
          if (v < -1e-6 || u + v > 1.0 + 1e-6) {
            continue;
          }

          final t = (e2x * qx + e2y * qy + e2z * qz) * invDet;
          if (t > 1e-7 && t <= maxDistance) {
            final nx = e1y * e2z - e1z * e2y;
            final ny = e1z * e2x - e1x * e2z;
            final nz = e1x * e2y - e1y * e2x;
            final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
            final invLen = nLen > 1e-12 ? 1.0 / nLen : 0.0;
            out.add(
              SurfaceRayHit(
                distance: t,
                point: Vector3(ox + dx * t, oy + dy * t, oz + dz * t),
                normal: Vector3(nx * invLen, ny * invLen, nz * invLen),
                barycentricU: u,
                barycentricV: v,
                triangleIndex: tri,
              ),
            );
          }
        }
      } else {
        _stack[sp++] = _rightChild[node];
        _stack[sp++] = _leftOrFirst[node];
      }
    }
  }

  /// Entry parameter `t >= 0` of the ray into [node]'s AABB, or
  /// `double.infinity` when missed or beyond [maxT].
  @pragma('vm:prefer-inline')
  double _rayBoxEntry(
    int node,
    double ox,
    double oy,
    double oz,
    double dx,
    double dy,
    double dz,
    double maxT,
  ) {
    final b = node * 6;
    final minX = _bounds[b] - 1e-5;
    final minY = _bounds[b + 1] - 1e-5;
    final minZ = _bounds[b + 2] - 1e-5;
    final maxX = _bounds[b + 3] + 1e-5;
    final maxY = _bounds[b + 4] + 1e-5;
    final maxZ = _bounds[b + 5] + 1e-5;

    var tMin = 0.0;
    var tMax = maxT;

    if (dx.abs() < 1e-12) {
      if (ox < minX || ox > maxX) {
        return double.infinity;
      }
    } else {
      final inv = 1.0 / dx;
      var t1 = (minX - ox) * inv;
      var t2 = (maxX - ox) * inv;
      if (t1 > t2) {
        final s = t1;
        t1 = t2;
        t2 = s;
      }
      if (t1 > tMin) {
        tMin = t1;
      }
      if (t2 < tMax) {
        tMax = t2;
      }
      if (tMin > tMax) {
        return double.infinity;
      }
    }

    if (dy.abs() < 1e-12) {
      if (oy < minY || oy > maxY) {
        return double.infinity;
      }
    } else {
      final inv = 1.0 / dy;
      var t1 = (minY - oy) * inv;
      var t2 = (maxY - oy) * inv;
      if (t1 > t2) {
        final s = t1;
        t1 = t2;
        t2 = s;
      }
      if (t1 > tMin) {
        tMin = t1;
      }
      if (t2 < tMax) {
        tMax = t2;
      }
      if (tMin > tMax) {
        return double.infinity;
      }
    }

    if (dz.abs() < 1e-12) {
      if (oz < minZ || oz > maxZ) {
        return double.infinity;
      }
    } else {
      final inv = 1.0 / dz;
      var t1 = (minZ - oz) * inv;
      var t2 = (maxZ - oz) * inv;
      if (t1 > t2) {
        final s = t1;
        t1 = t2;
        t2 = s;
      }
      if (t1 > tMin) {
        tMin = t1;
      }
      if (t2 < tMax) {
        tMax = t2;
      }
      if (tMin > tMax) {
        return double.infinity;
      }
    }

    return tMin;
  }
}
