import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';

/// Allocation-free flat median-split AABB Bounding Volume Hierarchy (BVH) over
/// the [Object3D]s of a [World3D].
///
/// Accelerates world-space AABB queries, camera frustum queries, and front-to-
/// back distance-pruned `World3D.raycast` / `raycastAll` from `O(N)` to
/// `O(log N)`.
class SceneSpatialIndex3D() {
  static const int _maxLeafSize = 4;

  final List<Object3D> _objects = [];
  Int32List _indices = Int32List(0);
  Float32List _objBounds = Float32List(0);
  Float32List _nodeBounds = Float32List(0);
  Int32List _nodeData = Int32List(0);
  Int32List _stack = Int32List(64);
  Float64List _stackDist = Float64List(64);

  int _nodeCount = 0;
  int _builtSceneVersion = -1;

  /// Number of indexed [Object3D]s in the most recent build.
  int get indexedObjectCount => _objects.length;

  /// Number of BVH nodes in the most recent build.
  int get nodeCount => _nodeCount;

  /// Number of narrowphase `Object3D.raycast` tests executed by the last
  /// [raycast] or [raycastAll] call.
  int lastRaycastCandidatesTested = 0;

  /// Marks the index out of date so the next query rebuilds it lazily.
  void invalidate() {
    _builtSceneVersion = -1;
  }

  /// Ensures the BVH is up to date for [world].
  void ensureBuilt(World3D world) {
    if (_builtSceneVersion == world.sceneVersion) {
      return;
    }
    _builtSceneVersion = world.sceneVersion;
    _rebuild(world);
  }

  void _rebuild(World3D world) {
    _objects.clear();
    void collect(Component3D parent) {
      for (final child in parent.children) {
        if (child is Object3D) {
          _objects.add(child);
        }
        if (child is Component3D) {
          collect(child);
        }
      }
    }

    for (final child in world.children) {
      if (child is Object3D) {
        _objects.add(child);
      }
      if (child is Component3D) {
        collect(child);
      }
    }

    final n = _objects.length;
    if (n == 0) {
      _nodeCount = 0;
      return;
    }

    if (_indices.length < n) {
      final cap = _nextPow2(n);
      _indices = Int32List(cap);
      _objBounds = Float32List(cap * 9);
      final maxNodes = math.max(4, cap * 2);
      _nodeBounds = Float32List(maxNodes * 6);
      _nodeData = Int32List(maxNodes * 2);
    }

    for (var i = 0; i < n; i++) {
      _indices[i] = i;
      final b = _objects[i].aabb;
      final min = b.min;
      final max = b.max;
      final o = i * 9;
      _objBounds[o] = min.x;
      _objBounds[o + 1] = min.y;
      _objBounds[o + 2] = min.z;
      _objBounds[o + 3] = max.x;
      _objBounds[o + 4] = max.y;
      _objBounds[o + 5] = max.z;
      _objBounds[o + 6] = 0.5 * (min.x + max.x);
      _objBounds[o + 7] = 0.5 * (min.y + max.y);
      _objBounds[o + 8] = 0.5 * (min.z + max.z);
    }

    _nodeCount = 0;
    _buildNode(0, n);
  }

  int _buildNode(int start, int end) {
    final node = _nodeCount++;
    if (_nodeCount * 6 > _nodeBounds.length) {
      final nextNodes = _nodeBounds.length ~/ 3;
      _nodeBounds = Float32List(nextNodes * 6)..setAll(0, _nodeBounds);
      _nodeData = Int32List(nextNodes * 2)..setAll(0, _nodeData);
    }

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

    for (var i = start; i < end; i++) {
      final idx = _indices[i] * 9;
      final x0 = _objBounds[idx];
      final y0 = _objBounds[idx + 1];
      final z0 = _objBounds[idx + 2];
      final x1 = _objBounds[idx + 3];
      final y1 = _objBounds[idx + 4];
      final z1 = _objBounds[idx + 5];
      final cx = _objBounds[idx + 6];
      final cy = _objBounds[idx + 7];
      final cz = _objBounds[idx + 8];
      if (x0 < minX) {
        minX = x0;
      }
      if (y0 < minY) {
        minY = y0;
      }
      if (z0 < minZ) {
        minZ = z0;
      }
      if (x1 > maxX) {
        maxX = x1;
      }
      if (y1 > maxY) {
        maxY = y1;
      }
      if (z1 > maxZ) {
        maxZ = z1;
      }
      if (cx < cMinX) {
        cMinX = cx;
      }
      if (cy < cMinY) {
        cMinY = cy;
      }
      if (cz < cMinZ) {
        cMinZ = cz;
      }
      if (cx > cMaxX) {
        cMaxX = cx;
      }
      if (cy > cMaxY) {
        cMaxY = cy;
      }
      if (cz > cMaxZ) {
        cMaxZ = cz;
      }
    }

    final nb = node * 6;
    _nodeBounds[nb] = minX;
    _nodeBounds[nb + 1] = minY;
    _nodeBounds[nb + 2] = minZ;
    _nodeBounds[nb + 3] = maxX;
    _nodeBounds[nb + 4] = maxY;
    _nodeBounds[nb + 5] = maxZ;

    final count = end - start;
    if (count <= _maxLeafSize) {
      _nodeData[node * 2] = start;
      _nodeData[node * 2 + 1] = count;
      return node;
    }

    final ex = cMaxX - cMinX;
    final ey = cMaxY - cMinY;
    final ez = cMaxZ - cMinZ;
    final int axis;
    final double split;
    if (ex >= ey && ex >= ez) {
      axis = 6;
      split = 0.5 * (cMinX + cMaxX);
    } else if (ey >= ez) {
      axis = 7;
      split = 0.5 * (cMinY + cMaxY);
    } else {
      axis = 8;
      split = 0.5 * (cMinZ + cMaxZ);
    }

    var mid = start;
    for (var i = start; i < end; i++) {
      final id = _indices[i];
      if (_objBounds[id * 9 + axis] < split) {
        final tmp = _indices[mid];
        _indices[mid] = id;
        _indices[i] = tmp;
        mid++;
      }
    }
    if (mid == start || mid == end) {
      mid = (start + end) >> 1;
    }

    final left = _buildNode(start, mid);
    final right = _buildNode(mid, end);
    // Internal node convention: `count <= 0` stores `-right`, `data0` = `left`.
    _nodeData[node * 2] = left;
    _nodeData[node * 2 + 1] = -right;
    return node;
  }

  /// Appends every [Object3D] whose world AABB overlaps [bounds] into [out].
  List<Object3D> queryAabb(
    World3D world,
    Aabb3 bounds, {
    List<Object3D>? out,
  }) {
    final result = out ?? <Object3D>[];
    ensureBuilt(world);
    if (_nodeCount == 0) {
      return result;
    }
    final qMinX = bounds.min.x;
    final qMinY = bounds.min.y;
    final qMinZ = bounds.min.z;
    final qMaxX = bounds.max.x;
    final qMaxY = bounds.max.y;
    final qMaxZ = bounds.max.z;

    var sp = 0;
    _pushNode(sp++, 0, 0);
    while (sp > 0) {
      final node = _stack[--sp];
      final nb = node * 6;
      if (_nodeBounds[nb + 3] < qMinX ||
          _nodeBounds[nb] > qMaxX ||
          _nodeBounds[nb + 4] < qMinY ||
          _nodeBounds[nb + 1] > qMaxY ||
          _nodeBounds[nb + 5] < qMinZ ||
          _nodeBounds[nb + 2] > qMaxZ) {
        continue;
      }
      final d0 = _nodeData[node * 2];
      final d1 = _nodeData[node * 2 + 1];
      if (d1 > 0) {
        for (var i = d0; i < d0 + d1; i++) {
          final id = _indices[i];
          final ob = id * 9;
          if (_objBounds[ob + 3] >= qMinX &&
              _objBounds[ob] <= qMaxX &&
              _objBounds[ob + 4] >= qMinY &&
              _objBounds[ob + 1] <= qMaxY &&
              _objBounds[ob + 5] >= qMinZ &&
              _objBounds[ob + 2] <= qMaxZ) {
            result.add(_objects[id]);
          }
        }
      } else {
        _pushNode(sp++, -d1, 0);
        _pushNode(sp++, d0, 0);
      }
    }
    return result;
  }

  final Aabb3 _scratchAabb = Aabb3();

  /// Appends every [Object3D] whose world AABB intersects [frustum] into [out].
  List<Object3D> queryFrustum(
    World3D world,
    Frustum frustum, {
    List<Object3D>? out,
  }) {
    final result = out ?? <Object3D>[];
    ensureBuilt(world);
    if (_nodeCount == 0) {
      return result;
    }

    var sp = 0;
    _pushNode(sp++, 0, 0);
    while (sp > 0) {
      final node = _stack[--sp];
      final nb = node * 6;
      _scratchAabb.min.setValues(
        _nodeBounds[nb],
        _nodeBounds[nb + 1],
        _nodeBounds[nb + 2],
      );
      _scratchAabb.max.setValues(
        _nodeBounds[nb + 3],
        _nodeBounds[nb + 4],
        _nodeBounds[nb + 5],
      );
      if (!frustum.intersectsWithAabb3(_scratchAabb)) {
        continue;
      }
      final d0 = _nodeData[node * 2];
      final d1 = _nodeData[node * 2 + 1];
      if (d1 > 0) {
        for (var i = d0; i < d0 + d1; i++) {
          final obj = _objects[_indices[i]];
          if (frustum.intersectsWithAabb3(obj.aabb)) {
            result.add(obj);
          }
        }
      } else {
        _pushNode(sp++, -d1, 0);
        _pushNode(sp++, d0, 0);
      }
    }
    return result;
  }

  /// Closest narrowphase triangle hit along [worldRay], traversing BVH nodes
  /// front-to-back and pruning subtrees beyond the closest hit distance.
  RayHit3D? raycast(
    World3D world,
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    lastRaycastCandidatesTested = 0;
    ensureBuilt(world);
    if (_nodeCount == 0) {
      return null;
    }

    final ox = worldRay.origin.x;
    final oy = worldRay.origin.y;
    final oz = worldRay.origin.z;
    final invDx = 1.0 / worldRay.direction.x;
    final invDy = 1.0 / worldRay.direction.y;
    final invDz = 1.0 / worldRay.direction.z;

    var limit = maxDistance;
    final rootT = _intersectAabb(
      _nodeBounds,
      0,
      ox,
      oy,
      oz,
      invDx,
      invDy,
      invDz,
      limit,
    );
    if (!rootT.isFinite || rootT > limit) {
      return null;
    }

    RayHit3D? best;
    var sp = 0;
    _pushNode(sp++, 0, rootT);

    while (sp > 0) {
      sp--;
      final node = _stack[sp];
      if (!_stackDist[sp].isFinite || _stackDist[sp] > limit) {
        continue;
      }

      final d0 = _nodeData[node * 2];
      final d1 = _nodeData[node * 2 + 1];
      if (d1 > 0) {
        for (var i = d0; i < d0 + d1; i++) {
          final id = _indices[i];
          final obj = _objects[id];
          if (filter != null && !filter(obj)) {
            continue;
          }
          final tObj = _intersectAabb(
            _objBounds,
            id * 9,
            ox,
            oy,
            oz,
            invDx,
            invDy,
            invDz,
            limit,
          );
          if (!tObj.isFinite || tObj > limit) {
            continue;
          }
          lastRaycastCandidatesTested++;
          final hit = obj.raycast(
            worldRay,
            maxDistance: limit,
            cullMode: cullMode,
          );
          if (hit != null && hit.distance < limit) {
            limit = hit.distance;
            best = hit;
          }
        }
      } else {
        final left = d0;
        final right = -d1;
        final tL = _intersectAabb(
          _nodeBounds,
          left * 6,
          ox,
          oy,
          oz,
          invDx,
          invDy,
          invDz,
          limit,
        );
        final tR = _intersectAabb(
          _nodeBounds,
          right * 6,
          ox,
          oy,
          oz,
          invDx,
          invDy,
          invDz,
          limit,
        );
        final hitL = tL.isFinite && tL <= limit;
        final hitR = tR.isFinite && tR <= limit;
        if (hitL && hitR) {
          if (tL <= tR) {
            _pushNode(sp++, right, tR);
            _pushNode(sp++, left, tL);
          } else {
            _pushNode(sp++, left, tL);
            _pushNode(sp++, right, tR);
          }
        } else if (hitL) {
          _pushNode(sp++, left, tL);
        } else if (hitR) {
          _pushNode(sp++, right, tR);
        }
      }
    }
    return best;
  }

  /// All narrowphase hits along [worldRay] up to [maxDistance], sorted by
  /// ascending hit distance.
  List<RayHit3D> raycastAll(
    World3D world,
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
    bool Function(Object3D object)? filter,
  }) {
    lastRaycastCandidatesTested = 0;
    final hits = <RayHit3D>[];
    ensureBuilt(world);
    if (_nodeCount == 0) {
      return hits;
    }

    final ox = worldRay.origin.x;
    final oy = worldRay.origin.y;
    final oz = worldRay.origin.z;
    final invDx = 1.0 / worldRay.direction.x;
    final invDy = 1.0 / worldRay.direction.y;
    final invDz = 1.0 / worldRay.direction.z;

    final rootT = _intersectAabb(
      _nodeBounds,
      0,
      ox,
      oy,
      oz,
      invDx,
      invDy,
      invDz,
      maxDistance,
    );
    if (!rootT.isFinite || rootT > maxDistance) {
      return hits;
    }

    var sp = 0;
    _pushNode(sp++, 0, rootT);
    while (sp > 0) {
      sp--;
      final node = _stack[sp];
      final d0 = _nodeData[node * 2];
      final d1 = _nodeData[node * 2 + 1];
      if (d1 > 0) {
        for (var i = d0; i < d0 + d1; i++) {
          final id = _indices[i];
          final obj = _objects[id];
          if (filter != null && !filter(obj)) {
            continue;
          }
          final tObj = _intersectAabb(
            _objBounds,
            id * 9,
            ox,
            oy,
            oz,
            invDx,
            invDy,
            invDz,
            maxDistance,
          );
          if (!tObj.isFinite || tObj > maxDistance) {
            continue;
          }
          lastRaycastCandidatesTested++;
          final hit = obj.raycast(
            worldRay,
            maxDistance: maxDistance,
            cullMode: cullMode,
          );
          if (hit != null) {
            hits.add(hit);
          }
        }
      } else {
        final left = d0;
        final right = -d1;
        final tL = _intersectAabb(
          _nodeBounds,
          left * 6,
          ox,
          oy,
          oz,
          invDx,
          invDy,
          invDz,
          maxDistance,
        );
        final tR = _intersectAabb(
          _nodeBounds,
          right * 6,
          ox,
          oy,
          oz,
          invDx,
          invDy,
          invDz,
          maxDistance,
        );
        if (tL.isFinite && tL <= maxDistance) {
          _pushNode(sp++, left, tL);
        }
        if (tR.isFinite && tR <= maxDistance) {
          _pushNode(sp++, right, tR);
        }
      }
    }
    hits.sort((a, b) => a.distance.compareTo(b.distance));
    return hits;
  }

  void _pushNode(int sp, int node, double dist) {
    if (sp >= _stack.length) {
      final next = _stack.length * 2;
      _stack = Int32List(next)..setAll(0, _stack);
      _stackDist = Float64List(next)..setAll(0, _stackDist);
    }
    _stack[sp] = node;
    _stackDist[sp] = dist;
  }

  static double _intersectAabb(
    Float32List b,
    int o,
    double ox,
    double oy,
    double oz,
    double invDx,
    double invDy,
    double invDz,
    double maxDist,
  ) {
    final tx1 = (b[o] - ox) * invDx;
    final tx2 = (b[o + 3] - ox) * invDx;
    var tMin = tx1 < tx2 ? tx1 : tx2;
    var tMax = tx1 > tx2 ? tx1 : tx2;

    final ty1 = (b[o + 1] - oy) * invDy;
    final ty2 = (b[o + 4] - oy) * invDy;
    final tyMin = ty1 < ty2 ? ty1 : ty2;
    final tyMax = ty1 > ty2 ? ty1 : ty2;
    if (tyMin > tMin) {
      tMin = tyMin;
    }
    if (tyMax < tMax) {
      tMax = tyMax;
    }

    final tz1 = (b[o + 2] - oz) * invDz;
    final tz2 = (b[o + 5] - oz) * invDz;
    final tzMin = tz1 < tz2 ? tz1 : tz2;
    final tzMax = tz1 > tz2 ? tz1 : tz2;
    if (tzMin > tMin) {
      tMin = tzMin;
    }
    if (tzMax < tMax) {
      tMax = tzMax;
    }

    if (tMax < 0 || tMin > tMax || tMin > maxDist) {
      return double.infinity;
    }
    return tMin < 0 ? 0.0 : tMin;
  }

  static int _nextPow2(int v) {
    var cap = 16;
    while (cap < v) {
      cap *= 2;
    }
    return cap;
  }
}
