import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/components.dart' show Component;
import 'package:flame_3d/camera.dart' show World3D;
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart' show VertexLayout;
import 'package:flame_3d/model.dart' show ModelComponent;
import 'package:flame_3d/resources.dart';

/// Time-of-impact (`toi` in `[0..1]`) hit returned by [ShapeCast3D].
class ShapeCastHit3D({
  required final double toi,
  required final double distance,
  required final Vector3 point,
  required final Vector3 normal,
  final Component3D? component,
  final Collider3D? collider,
});

/// Continuous swept 3D shape-casting (`sphereCast`, `capsuleCast`, and
/// `convexCast`) against [CollisionSystem3D] colliders and static
/// [MeshComponent] / [TerrainMesh3D] / [ModelComponent] surfaces.
abstract final class ShapeCast3D._() {
  /// Sweeps a sphere of [radius] from [origin] along [delta], returning the
  /// earliest [ShapeCastHit3D] (`toi` in `[0..1]`) or `null` when clear.
  static ShapeCastHit3D? sphereCast({
    required Vector3 origin,
    required double radius,
    required Vector3 delta,
    CollisionSystem3D? collisionSystem,
    World3D? world,
    Iterable<Object3D>? staticGeometry,
    int collisionMask = 0xFFFFFFFF,
    bool includeTriggers = false,
    bool Function(Component3D candidate)? filter,
  }) {
    final shape = SphereShape3D(radius: radius);
    _startMat.setIdentity();
    _startMat.setTranslation(origin);
    return convexCast(
      shape: shape,
      startTransform: _startMat,
      delta: delta,
      collisionSystem: collisionSystem,
      world: world,
      staticGeometry: staticGeometry,
      collisionMask: collisionMask,
      includeTriggers: includeTriggers,
      filter: filter,
    );
  }

  /// Sweeps a capsule of [radius] and total [height] aligned to [axis] (with
  /// optional [rotation]) from [origin] along [delta], returning the earliest
  /// [ShapeCastHit3D] (`toi` in `[0..1]`) or `null` when clear.
  static ShapeCastHit3D? capsuleCast({
    required Vector3 origin,
    required double radius,
    required double height,
    required Vector3 delta,
    Axis3D axis = Axis3D.y,
    Quaternion? rotation,
    CollisionSystem3D? collisionSystem,
    World3D? world,
    Iterable<Object3D>? staticGeometry,
    int collisionMask = 0xFFFFFFFF,
    bool includeTriggers = false,
    bool Function(Component3D candidate)? filter,
  }) {
    final shape = CapsuleShape3D(radius: radius, height: height, axis: axis);
    _startMat.setFromTranslationRotationScale(
      origin,
      rotation ?? _identityQuat,
      _unitScale,
    );
    return convexCast(
      shape: shape,
      startTransform: _startMat,
      delta: delta,
      collisionSystem: collisionSystem,
      world: world,
      staticGeometry: staticGeometry,
      collisionMask: collisionMask,
      includeTriggers: includeTriggers,
      filter: filter,
    );
  }

  /// Sweeps an arbitrary convex [shape] from [startTransform] along [delta].
  static ShapeCastHit3D? convexCast({
    required Shape3D shape,
    required Matrix4 startTransform,
    required Vector3 delta,
    CollisionSystem3D? collisionSystem,
    World3D? world,
    Iterable<Object3D>? staticGeometry,
    int collisionMask = 0xFFFFFFFF,
    bool includeTriggers = false,
    bool Function(Component3D candidate)? filter,
  }) {
    final sweepLen2 = delta.length2;
    if (sweepLen2 <= 1e-16) {
      return null;
    }
    final sweepLen = math.sqrt(sweepLen2);

    shape.computeWorldAabb(startTransform, _aabbStart);
    _endMat.setFrom(startTransform);
    _endMat.storage[12] += delta.x;
    _endMat.storage[13] += delta.y;
    _endMat.storage[14] += delta.z;
    shape.computeWorldAabb(_endMat, _aabbEnd);

    _sweptAabb
      ..min.setValues(
        math.min(_aabbStart.min.x, _aabbEnd.min.x),
        math.min(_aabbStart.min.y, _aabbEnd.min.y),
        math.min(_aabbStart.min.z, _aabbEnd.min.z),
      )
      ..max.setValues(
        math.max(_aabbStart.max.x, _aabbEnd.max.x),
        math.max(_aabbStart.max.y, _aabbEnd.max.y),
        math.max(_aabbStart.max.z, _aabbEnd.max.z),
      );

    ShapeCastHit3D? best;
    var maxToi = 1.0;

    // 1. Test against CollisionSystem3D colliders.
    if (collisionSystem != null) {
      final colliders = collisionSystem.collectColliders(_colliderScratch);
      for (var i = 0; i < colliders.length; i++) {
        final c = colliders[i];
        if (!includeTriggers && c.isTrigger) {
          continue;
        }
        if ((c.collisionLayer & collisionMask) == 0) {
          continue;
        }
        final host = c.hostComponent;
        if (filter != null && (!filter(c) || !filter(host))) {
          continue;
        }
        final box = c.colliderWorldAabb;
        if (!_boxesOverlap(_sweptAabb, box)) {
          continue;
        }
        final hit = _sweepShapeAgainstCollider(
          shape,
          startTransform,
          delta,
          sweepLen,
          c,
          maxToi,
        );
        if (hit != null && hit.toi <= maxToi) {
          maxToi = hit.toi;
          best = hit;
        }
      }
    }

    // 2. Test against static Object3D geometry (`staticGeometry` + `world`).
    void testObject(Object3D obj) {
      if (filter != null && !filter(obj)) {
        return;
      }
      if (!_boxesOverlap(_sweptAabb, obj.aabb)) {
        return;
      }
      if (obj is MeshComponent) {
        final hit = _sweepShapeAgainstMesh(
          shape,
          startTransform,
          delta,
          sweepLen,
          obj,
          obj.mesh,
          obj.worldTransformMatrix,
          maxToi,
        );
        if (hit != null && hit.toi <= maxToi) {
          maxToi = hit.toi;
          best = hit;
        }
      } else if (obj is ModelComponent) {
        final ws = obj.evaluatePose();
        for (final node in ws.orderedNodes) {
          final mesh = node.node.mesh;
          if (mesh == null) {
            continue;
          }
          _nodeMat
            ..setFrom(obj.worldTransformMatrix)
            ..multiply(node.combinedTransform);
          final hit = _sweepShapeAgainstMesh(
            shape,
            startTransform,
            delta,
            sweepLen,
            obj,
            mesh,
            _nodeMat,
            maxToi,
          );
          if (hit != null && hit.toi <= maxToi) {
            maxToi = hit.toi;
            best = hit;
          }
        }
      }
    }

    if (staticGeometry != null) {
      for (final obj in staticGeometry) {
        testObject(obj);
      }
    }

    if (world != null) {
      void visit(Component comp) {
        if (comp is Component3D) {
          if (!_boxesOverlap(_sweptAabb, comp.aabb)) {
            return;
          }
          if (comp is Object3D) {
            // Avoid double-testing if already passed in `staticGeometry`.
            var alreadyTested = false;
            if (staticGeometry != null) {
              for (final s in staticGeometry) {
                if (identical(s, comp)) {
                  alreadyTested = true;
                  break;
                }
              }
            }
            if (!alreadyTested) {
              testObject(comp);
            }
          }
        }
        for (final child in comp.children) {
          visit(child);
        }
      }

      for (final child in world.children) {
        visit(child);
      }
    }

    return best;
  }

  static ShapeCastHit3D? _sweepShapeAgainstCollider(
    Shape3D shapeA,
    Matrix4 startA,
    Vector3 delta,
    double sweepLen,
    Collider3D colliderB,
    double maxToi,
  ) {
    final matB = colliderB.colliderWorldMatrix;
    final shapeB = colliderB.shape;
    final res = _gjkConvexSweep(
      (dir, out) => shapeA.supportPoint(dir, startA, out),
      (dir, out) => shapeB.supportPoint(dir, matB, out),
      () => Narrowphase3D.test(shapeA, startA, shapeB, matB),
      _centerOf(startA, _cA),
      _centerOf(matB, _cB),
      delta,
      maxToi,
    );
    if (res == null) {
      return null;
    }
    return ShapeCastHit3D(
      toi: res.toi,
      distance: res.toi * sweepLen,
      point: res.point,
      normal: res.normal,
      component: colliderB.hostComponent,
      collider: colliderB,
    );
  }

  static ShapeCastHit3D? _sweepShapeAgainstMesh(
    Shape3D shapeA,
    Matrix4 startA,
    Vector3 delta,
    double sweepLen,
    Object3D owner,
    Mesh mesh,
    Matrix4 meshMatrix,
    double initialMaxToi,
  ) {
    _invMesh.setFrom(meshMatrix);
    if (_invMesh.invert().abs() < 1e-15) {
      return null;
    }

    _localSweptAabb
      ..setFrom(_sweptAabb)
      ..transform(_invMesh);

    ShapeCastHit3D? best;
    var maxToi = initialMaxToi;
    final m = meshMatrix.storage;

    for (final surface in mesh.surfaces) {
      if (surface.indexCount < 3 ||
          !_boxesOverlap(_localSweptAabb, surface.aabb)) {
        continue;
      }
      final bvhRef = surface.bvh;
      if (bvhRef.triangleCount == 0) {
        continue;
      }
      final tree = _meshAabbTrees[bvhRef] ??= _SweepSurfaceTree.build(surface);
      _triCandidates.clear();
      tree.queryAabb(_localSweptAabb, _triCandidates);
      if (_triCandidates.isEmpty) {
        continue;
      }

      final positions = surface.positions;
      final indices = surface.indices;

      for (var i = 0; i < _triCandidates.length; i++) {
        final tri = _triCandidates[i];
        final base = tri * 3;
        final i0 = indices[base] * 3;
        final i1 = indices[base + 1] * 3;
        final i2 = indices[base + 2] * 3;

        _transformVert(
          m,
          positions[i0],
          positions[i0 + 1],
          positions[i0 + 2],
          _tv0,
        );
        _transformVert(
          m,
          positions[i1],
          positions[i1 + 1],
          positions[i1 + 2],
          _tv1,
        );
        _transformVert(
          m,
          positions[i2],
          positions[i2 + 1],
          positions[i2 + 2],
          _tv2,
        );

        _triCenter.setValues(
          (_tv0.x + _tv1.x + _tv2.x) * (1.0 / 3.0),
          (_tv0.y + _tv1.y + _tv2.y) * (1.0 / 3.0),
          (_tv0.z + _tv1.z + _tv2.z) * (1.0 / 3.0),
        );

        final res = _gjkConvexSweep(
          (dir, out) => shapeA.supportPoint(dir, startA, out),
          (dir, out) => _triSupport(_tv0, _tv1, _tv2, dir, out),
          () => Narrowphase3D.intersectShapeWithTriangle(
            shapeA,
            startA,
            _tv0,
            _tv1,
            _tv2,
          ),
          _centerOf(startA, _cA),
          _triCenter,
          delta,
          maxToi,
        );
        if (res != null && res.toi <= maxToi) {
          maxToi = res.toi;
          best = ShapeCastHit3D(
            toi: res.toi,
            distance: res.toi * sweepLen,
            point: res.point,
            normal: res.normal,
            component: owner,
          );
        }
      }
    }
    return best;
  }

  /// Van den Bergen's GJK Raycast (`x(t) = t * delta` entering Minkowski
  /// difference `M = B - A_0`, where `s_M(v) = s_B(v) - s_{A_0}(-v)`).
  static _SweepResult? _gjkConvexSweep(
    void Function(Vector3 dir, Vector3 out) supportA,
    void Function(Vector3 dir, Vector3 out) supportB,
    CollisionManifold3D? Function() initialOverlapTest,
    Vector3 centerA,
    Vector3 centerB,
    Vector3 delta,
    double maxToi,
  ) {
    void supportM(
      double dx,
      double dy,
      double dz,
      Vector3 outM,
      Vector3 outB,
    ) {
      _dirPos.setValues(dx, dy, dz);
      _dirNeg.setValues(-dx, -dy, -dz);
      supportB(_dirPos, outB);
      supportA(_dirNeg, _supA);
      outM
        ..setFrom(outB)
        ..sub(_supA);
    }

    var lambda = 0.0;
    var xx = 0.0;
    var xy = 0.0;
    var xz = 0.0;
    final rx = delta.x;
    final ry = delta.y;
    final rz = delta.z;

    var nx = 0.0;
    var ny = 0.0;
    var nz = 0.0;
    var hasNormal = false;

    var count = 0;

    for (var iter = 0; iter < 48; iter++) {
      if (count == 0) {
        var initDx = centerA.x - centerB.x;
        var initDy = centerA.y - centerB.y;
        var initDz = centerA.z - centerB.z;
        if (initDx * initDx + initDy * initDy + initDz * initDz < 1e-12) {
          initDx = -rx;
          initDy = -ry;
          initDz = -rz;
        }
        supportM(initDx, initDy, initDz, _supM, _supB);
        _mx[0] = _supM.x;
        _my[0] = _supM.y;
        _mz[0] = _supM.z;
        _bx[0] = _supB.x;
        _by[0] = _supB.y;
        _bz[0] = _supB.z;
        count = 1;
      }

      count = _reduceSimplexClosestTo(xx, xy, xz, count, _closestM, _closestB);
      final vx = xx - _closestM.x;
      final vy = xy - _closestM.y;
      final vz = xz - _closestM.z;
      final vLen2 = vx * vx + vy * vy + vz * vz;

      if (vLen2 <= 1e-10) {
        if (!hasNormal) {
          // Started overlapping at `lambda == 0`. Only report hit if moving
          // deeper into the obstacle; ignore parallel/separating skin touches!
          final manifold = initialOverlapTest();
          if (manifold == null || manifold.penetrationDepth <= 1e-4) {
            return null;
          }
          final obsNormal = -manifold.normal;
          if (obsNormal.dot(delta) >= -1e-6) {
            return null;
          }
          return _SweepResult(
            toi: 0.0,
            point: manifold.contactPointB.clone(),
            normal: obsNormal,
          );
        }
        final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
        return _SweepResult(
          toi: lambda,
          point: _closestB.clone(),
          normal: nLen > 1e-12
              ? Vector3(nx / nLen, ny / nLen, nz / nLen)
              : Vector3(-rx, -ry, -rz).normalized(),
        );
      }

      supportM(vx, vy, vz, _supM, _supB);
      final wx = _supM.x;
      final wy = _supM.y;
      final wz = _supM.z;

      final vp = vx * (xx - wx) + vy * (xy - wy) + vz * (xz - wz);
      final vr = vx * rx + vy * ry + vz * rz;

      if (vp > 0.0) {
        if (vr >= -1e-12) {
          return null;
        }
        lambda += vp / (-vr);
        if (lambda > maxToi) {
          return null;
        }
        xx = lambda * rx;
        xy = lambda * ry;
        xz = lambda * rz;
        nx = vx;
        ny = vy;
        nz = vz;
        hasNormal = true;
      }

      var duplicate = false;
      for (var i = 0; i < count; i++) {
        final dx = _mx[i] - wx;
        final dy = _my[i] - wy;
        final dz = _mz[i] - wz;
        if (dx * dx + dy * dy + dz * dz <= 1e-11) {
          duplicate = true;
          break;
        }
      }
      if (duplicate) {
        if (vp > 1e-6) {
          return null;
        }
        if (!hasNormal) {
          final manifold = initialOverlapTest();
          if (manifold == null || manifold.penetrationDepth <= 1e-4) {
            return null;
          }
          final obsNormal = -manifold.normal;
          if (obsNormal.dot(delta) >= -1e-6) {
            return null;
          }
          return _SweepResult(
            toi: 0.0,
            point: manifold.contactPointB.clone(),
            normal: obsNormal,
          );
        }
        final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
        return _SweepResult(
          toi: lambda,
          point: _closestB.clone(),
          normal: nLen > 1e-12
              ? Vector3(nx / nLen, ny / nLen, nz / nLen)
              : Vector3(-rx, -ry, -rz).normalized(),
        );
      }

      final slot = count < 4 ? count++ : 3;
      _mx[slot] = wx;
      _my[slot] = wy;
      _mz[slot] = wz;
      _bx[slot] = _supB.x;
      _by[slot] = _supB.y;
      _bz[slot] = _supB.z;
    }

    if (hasNormal && lambda <= maxToi) {
      final d2 =
          (xx - _closestM.x) * (xx - _closestM.x) +
          (xy - _closestM.y) * (xy - _closestM.y) +
          (xz - _closestM.z) * (xz - _closestM.z);
      if (d2 <= 1e-6) {
        final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
        return _SweepResult(
          toi: lambda,
          point: _closestB.clone(),
          normal: nLen > 1e-12
              ? Vector3(nx / nLen, ny / nLen, nz / nLen)
              : Vector3(-rx, -ry, -rz).normalized(),
        );
      }
    }
    return null;
  }

  static int _reduceSimplexClosestTo(
    double px,
    double py,
    double pz,
    int count,
    Vector3 outM,
    Vector3 outB,
  ) {
    if (count == 1) {
      outM.setValues(_mx[0], _my[0], _mz[0]);
      outB.setValues(_bx[0], _by[0], _bz[0]);
      return 1;
    }
    if (count == 2) {
      final ax = _mx[0] - px;
      final ay = _my[0] - py;
      final az = _mz[0] - pz;
      final abx = (_mx[1] - px) - ax;
      final aby = (_my[1] - py) - ay;
      final abz = (_mz[1] - pz) - az;
      final denom = abx * abx + aby * aby + abz * abz;
      if (denom <= 1e-16) {
        outM.setValues(_mx[0], _my[0], _mz[0]);
        outB.setValues(_bx[0], _by[0], _bz[0]);
        return 1;
      }
      final t = -(ax * abx + ay * aby + az * abz) / denom;
      if (t <= 0.0) {
        outM.setValues(_mx[0], _my[0], _mz[0]);
        outB.setValues(_bx[0], _by[0], _bz[0]);
        return 1;
      }
      if (t >= 1.0) {
        _copySlot(1, 0);
        outM.setValues(_mx[0], _my[0], _mz[0]);
        outB.setValues(_bx[0], _by[0], _bz[0]);
        return 1;
      }
      outM.setValues(_mx[0] + t * abx, _my[0] + t * aby, _mz[0] + t * abz);
      outB.setValues(
        _bx[0] + t * (_bx[1] - _bx[0]),
        _by[0] + t * (_by[1] - _by[0]),
        _bz[0] + t * (_bz[1] - _bz[0]),
      );
      return 2;
    }
    if (count == 3) {
      return _reduceTriangleClosestTo(px, py, pz, outM, outB);
    }
    return _reduceTetraClosestTo(px, py, pz, outM, outB);
  }

  static void _copySlot(int from, int to) {
    _mx[to] = _mx[from];
    _my[to] = _my[from];
    _mz[to] = _mz[from];
    _bx[to] = _bx[from];
    _by[to] = _by[from];
    _bz[to] = _bz[from];
  }

  static int _reduceTriangleClosestTo(
    double px,
    double py,
    double pz,
    Vector3 outM,
    Vector3 outB,
  ) {
    final ax = _mx[0] - px;
    final ay = _my[0] - py;
    final az = _mz[0] - pz;
    final bx = _mx[1] - px;
    final by = _my[1] - py;
    final bz = _mz[1] - pz;
    final cx = _mx[2] - px;
    final cy = _my[2] - py;
    final cz = _mz[2] - pz;

    final abx = bx - ax;
    final aby = by - ay;
    final abz = bz - az;
    final acx = cx - ax;
    final acy = cy - ay;
    final acz = cz - az;

    final d1 = -(abx * ax + aby * ay + abz * az);
    final d2 = -(acx * ax + acy * ay + acz * az);
    if (d1 <= 0.0 && d2 <= 0.0) {
      outM.setValues(_mx[0], _my[0], _mz[0]);
      outB.setValues(_bx[0], _by[0], _bz[0]);
      return 1;
    }

    final d3 = -(abx * bx + aby * by + abz * bz);
    final d4 = -(acx * bx + acy * by + acz * bz);
    if (d3 >= 0.0 && d4 <= d3) {
      _copySlot(1, 0);
      outM.setValues(_mx[0], _my[0], _mz[0]);
      outB.setValues(_bx[0], _by[0], _bz[0]);
      return 1;
    }

    final vc = d1 * d4 - d3 * d2;
    if (vc <= 0.0 && d1 >= 0.0 && d3 <= 0.0) {
      final v = d1 / (d1 - d3);
      outM.setValues(_mx[0] + v * abx, _my[0] + v * aby, _mz[0] + v * abz);
      outB.setValues(
        _bx[0] + v * (_bx[1] - _bx[0]),
        _by[0] + v * (_by[1] - _by[0]),
        _bz[0] + v * (_bz[1] - _bz[0]),
      );
      return 2;
    }

    final d5 = -(abx * cx + aby * cy + abz * cz);
    final d6 = -(acx * cx + acy * cy + acz * cz);
    if (d6 >= 0.0 && d5 <= d6) {
      _copySlot(2, 0);
      outM.setValues(_mx[0], _my[0], _mz[0]);
      outB.setValues(_bx[0], _by[0], _bz[0]);
      return 1;
    }

    final vb = d5 * d2 - d1 * d6;
    if (vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0) {
      final w = d2 / (d2 - d6);
      outM.setValues(_mx[0] + w * acx, _my[0] + w * acy, _mz[0] + w * acz);
      outB.setValues(
        _bx[0] + w * (_bx[2] - _bx[0]),
        _by[0] + w * (_by[2] - _by[0]),
        _bz[0] + w * (_bz[2] - _bz[0]),
      );
      _copySlot(2, 1);
      return 2;
    }

    final va = d3 * d6 - d5 * d4;
    if (va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0) {
      final w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
      outM.setValues(
        _mx[1] + w * (_mx[2] - _mx[1]),
        _my[1] + w * (_my[2] - _my[1]),
        _mz[1] + w * (_mz[2] - _mz[1]),
      );
      outB.setValues(
        _bx[1] + w * (_bx[2] - _bx[1]),
        _by[1] + w * (_by[2] - _by[1]),
        _bz[1] + w * (_bz[2] - _bz[1]),
      );
      _copySlot(1, 0);
      _copySlot(2, 1);
      return 2;
    }

    final denom = 1.0 / (va + vb + vc);
    final v = vb * denom;
    final w = vc * denom;
    final u = 1.0 - v - w;
    outM.setValues(
      _mx[0] * u + _mx[1] * v + _mx[2] * w,
      _my[0] * u + _my[1] * v + _my[2] * w,
      _mz[0] * u + _mz[1] * v + _mz[2] * w,
    );
    outB.setValues(
      _bx[0] * u + _bx[1] * v + _bx[2] * w,
      _by[0] * u + _by[1] * v + _by[2] * w,
      _bz[0] * u + _bz[1] * v + _bz[2] * w,
    );
    return 3;
  }

  static int _reduceTetraClosestTo(
    double px,
    double py,
    double pz,
    Vector3 outM,
    Vector3 outB,
  ) {
    const faces = [
      (0, 1, 2, 3),
      (0, 2, 3, 1),
      (0, 3, 1, 2),
      (1, 3, 2, 0),
    ];
    for (var k = 0; k < 4; k++) {
      _tmx[k] = _mx[k];
      _tmy[k] = _my[k];
      _tmz[k] = _mz[k];
      _tbx[k] = _bx[k];
      _tby[k] = _by[k];
      _tbz[k] = _bz[k];
    }

    var bestD2 = double.infinity;
    var bestCount = 4;
    final bestMx = Float64List(3);
    final bestMy = Float64List(3);
    final bestMz = Float64List(3);
    final bestBx = Float64List(3);
    final bestBy = Float64List(3);
    final bestBz = Float64List(3);
    var bestOutMx = px;
    var bestOutMy = py;
    var bestOutMz = pz;
    var bestOutBx = _tbx[0];
    var bestOutBy = _tby[0];
    var bestOutBz = _tbz[0];
    var outsideAny = false;

    for (final (i0, i1, i2, opp) in faces) {
      final e1x = _tmx[i1] - _tmx[i0];
      final e1y = _tmy[i1] - _tmy[i0];
      final e1z = _tmz[i1] - _tmz[i0];
      final e2x = _tmx[i2] - _tmx[i0];
      final e2y = _tmy[i2] - _tmy[i0];
      final e2z = _tmz[i2] - _tmz[i0];
      final fnx = e1y * e2z - e1z * e2y;
      final fny = e1z * e2x - e1x * e2z;
      final fnz = e1x * e2y - e1y * e2x;

      final signP =
          fnx * (px - _tmx[i0]) + fny * (py - _tmy[i0]) + fnz * (pz - _tmz[i0]);
      final signOpp =
          fnx * (_tmx[opp] - _tmx[i0]) +
          fny * (_tmy[opp] - _tmy[i0]) +
          fnz * (_tmz[opp] - _tmz[i0]);

      if (signP * signOpp <= 0.0) {
        outsideAny = true;
        final indices = [i0, i1, i2];
        for (var s = 0; s < 3; s++) {
          final src = indices[s];
          _mx[s] = _tmx[src];
          _my[s] = _tmy[src];
          _mz[s] = _tmz[src];
          _bx[s] = _tbx[src];
          _by[s] = _tby[src];
          _bz[s] = _tbz[src];
        }
        final cnt = _reduceTriangleClosestTo(px, py, pz, outM, outB);
        final dx = outM.x - px;
        final dy = outM.y - py;
        final dz = outM.z - pz;
        final d2 = dx * dx + dy * dy + dz * dz;
        if (d2 < bestD2) {
          bestD2 = d2;
          bestCount = cnt;
          bestOutMx = outM.x;
          bestOutMy = outM.y;
          bestOutMz = outM.z;
          bestOutBx = outB.x;
          bestOutBy = outB.y;
          bestOutBz = outB.z;
          for (var s = 0; s < cnt; s++) {
            bestMx[s] = _mx[s];
            bestMy[s] = _my[s];
            bestMz[s] = _mz[s];
            bestBx[s] = _bx[s];
            bestBy[s] = _by[s];
            bestBz[s] = _bz[s];
          }
        }
      }
    }

    if (!outsideAny) {
      for (var k = 0; k < 4; k++) {
        _mx[k] = _tmx[k];
        _my[k] = _tmy[k];
        _mz[k] = _tmz[k];
        _bx[k] = _tbx[k];
        _by[k] = _tby[k];
        _bz[k] = _tbz[k];
      }
      outM.setValues(px, py, pz);
      outB.setValues(_tbx[0], _tby[0], _tbz[0]);
      return 4;
    }

    for (var s = 0; s < bestCount; s++) {
      _mx[s] = bestMx[s];
      _my[s] = bestMy[s];
      _mz[s] = bestMz[s];
      _bx[s] = bestBx[s];
      _by[s] = bestBy[s];
      _bz[s] = bestBz[s];
    }
    outM.setValues(bestOutMx, bestOutMy, bestOutMz);
    outB.setValues(bestOutBx, bestOutBy, bestOutBz);
    return bestCount;
  }

  static void _triSupport(
    Vector3 v0,
    Vector3 v1,
    Vector3 v2,
    Vector3 dir,
    Vector3 out,
  ) {
    final d0 = v0.dot(dir);
    final d1 = v1.dot(dir);
    final d2 = v2.dot(dir);
    if (d0 >= d1 && d0 >= d2) {
      out.setFrom(v0);
    } else if (d1 >= d2) {
      out.setFrom(v1);
    } else {
      out.setFrom(v2);
    }
  }

  static Vector3 _centerOf(Matrix4 m, Vector3 out) {
    final s = m.storage;
    out.setValues(s[12], s[13], s[14]);
    return out;
  }

  static void _transformVert(
    Float32List m,
    double x,
    double y,
    double z,
    Vector3 out,
  ) {
    out.setValues(
      m[0] * x + m[4] * y + m[8] * z + m[12],
      m[1] * x + m[5] * y + m[9] * z + m[13],
      m[2] * x + m[6] * y + m[10] * z + m[14],
    );
  }

  static bool _boxesOverlap(Aabb3 a, Aabb3 b) {
    return a.min.x <= b.max.x &&
        a.max.x >= b.min.x &&
        a.min.y <= b.max.y &&
        a.max.y >= b.min.y &&
        a.min.z <= b.max.z &&
        a.max.z >= b.min.z;
  }

  static final Quaternion _identityQuat = Quaternion.identity();
  static final Vector3 _unitScale = Vector3.all(1.0);
  static final Matrix4 _startMat = Matrix4.identity();
  static final Matrix4 _endMat = Matrix4.identity();
  static final Matrix4 _nodeMat = Matrix4.identity();
  static final Matrix4 _invMesh = Matrix4.identity();
  static final Aabb3 _aabbStart = Aabb3();
  static final Aabb3 _aabbEnd = Aabb3();
  static final Aabb3 _sweptAabb = Aabb3();
  static final Aabb3 _localSweptAabb = Aabb3();
  static final List<Collider3D> _colliderScratch = [];
  static final List<int> _triCandidates = [];
  static final Expando<_SweepSurfaceTree> _meshAabbTrees = Expando();

  static final Vector3 _cA = Vector3.zero();
  static final Vector3 _cB = Vector3.zero();
  static final Vector3 _tv0 = Vector3.zero();
  static final Vector3 _tv1 = Vector3.zero();
  static final Vector3 _tv2 = Vector3.zero();
  static final Vector3 _triCenter = Vector3.zero();

  static final Vector3 _dirPos = Vector3.zero();
  static final Vector3 _dirNeg = Vector3.zero();
  static final Vector3 _supA = Vector3.zero();
  static final Vector3 _supB = Vector3.zero();
  static final Vector3 _supM = Vector3.zero();
  static final Vector3 _closestM = Vector3.zero();
  static final Vector3 _closestB = Vector3.zero();

  static final Float64List _mx = Float64List(4);
  static final Float64List _my = Float64List(4);
  static final Float64List _mz = Float64List(4);
  static final Float64List _bx = Float64List(4);
  static final Float64List _by = Float64List(4);
  static final Float64List _bz = Float64List(4);

  static final Float64List _tmx = Float64List(4);
  static final Float64List _tmy = Float64List(4);
  static final Float64List _tmz = Float64List(4);
  static final Float64List _tbx = Float64List(4);
  static final Float64List _tby = Float64List(4);
  static final Float64List _tbz = Float64List(4);
}

class _SweepResult({
  required final double toi,
  required final Vector3 point,
  required final Vector3 normal,
});

class _SweepSurfaceTree._({
  required final int nodeCount,
  required final Float32List bounds,
  required final Int32List leftOrFirst,
  required final Int32List rightChild,
  required final Int32List counts,
  required final Int32List triangles,
}) {
  factory _SweepSurfaceTree.build(Surface surface) {
    final posOffset = surface.layout.offsetOf(VertexLayout.positionAttribute);
    final indices = surface.indices;
    final triCount = indices.length ~/ 3;
    if (posOffset == null || triCount == 0) {
      return _SweepSurfaceTree._(
        nodeCount: 0,
        bounds: Float32List(0),
        leftOrFirst: Int32List(0),
        rightChild: Int32List(0),
        counts: Int32List(0),
        triangles: Int32List(0),
      );
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

      final tb = t * 6;
      triBounds
        ..[tb] = math.min(x0, math.min(x1, x2))
        ..[tb + 1] = math.min(y0, math.min(y1, y2))
        ..[tb + 2] = math.min(z0, math.min(z1, z2))
        ..[tb + 3] = math.max(x0, math.max(x1, x2))
        ..[tb + 4] = math.max(y0, math.max(y1, y2))
        ..[tb + 5] = math.max(z0, math.max(z1, z2));

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
        cMinX = math.min(cMinX, centroids[cb]);
        cMinY = math.min(cMinY, centroids[cb + 1]);
        cMinZ = math.min(cMinZ, centroids[cb + 2]);
        cMaxX = math.max(cMaxX, centroids[cb]);
        cMaxY = math.max(cMaxY, centroids[cb + 1]);
        cMaxZ = math.max(cMaxZ, centroids[cb + 2]);
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
      var extent = cMaxX - cMinX;
      if (cMaxY - cMinY > extent) {
        axis = 1;
        split = 0.5 * (cMinY + cMaxY);
        extent = cMaxY - cMinY;
      }
      if (cMaxZ - cMinZ > extent) {
        axis = 2;
        split = 0.5 * (cMinZ + cMaxZ);
        extent = cMaxZ - cMinZ;
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
    return _SweepSurfaceTree._(
      nodeCount: nodeCount,
      bounds: Float32List.sublistView(bounds, 0, nodeCount * 6),
      leftOrFirst: Int32List.sublistView(leftOrFirst, 0, nodeCount),
      rightChild: Int32List.sublistView(rightChild, 0, nodeCount),
      counts: Int32List.sublistView(counts, 0, nodeCount),
      triangles: triIndices,
    );
  }

  final Int32List _stack = Int32List(128);

  void queryAabb(Aabb3 query, List<int> out) {
    if (nodeCount == 0) {
      return;
    }
    final qMinX = query.min.x - 1e-5;
    final qMinY = query.min.y - 1e-5;
    final qMinZ = query.min.z - 1e-5;
    final qMaxX = query.max.x + 1e-5;
    final qMaxY = query.max.y + 1e-5;
    final qMaxZ = query.max.z + 1e-5;

    var sp = 0;
    _stack[sp++] = 0;
    while (sp > 0) {
      final node = _stack[--sp];
      final nb = node * 6;
      if (bounds[nb] > qMaxX ||
          bounds[nb + 3] < qMinX ||
          bounds[nb + 1] > qMaxY ||
          bounds[nb + 4] < qMinY ||
          bounds[nb + 2] > qMaxZ ||
          bounds[nb + 5] < qMinZ) {
        continue;
      }
      final cnt = counts[node];
      if (cnt > 0) {
        final start = leftOrFirst[node];
        for (var i = start; i < start + cnt; i++) {
          out.add(triangles[i]);
        }
      } else {
        _stack[sp++] = rightChild[node];
        _stack[sp++] = leftOrFirst[node];
      }
    }
  }
}
