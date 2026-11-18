import 'dart:math' as math;

import 'package:flame_3d/camera.dart' show Ray, World3D;
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';

/// Capsule-based 3D kinematic character controller supporting `Y`-up and
/// `Z`-up worlds, smooth wall sliding, automatic stair/ledge step-up
/// (`<= stepOffset`), steep-cliff blocking (`> maxSlopeAngleRad`), and ground
/// snapping over [CollisionSystem3D] colliders and static mesh geometry.
class KinematicCharacterController3D({
  var double radius = 0.4,
  var double height = 1.8,
  var Axis3D upAxis = Axis3D.y,
  var double maxSlopeAngleRad = 0.8028514559173915,
  var double stepOffset = 0.35,
  var double skinWidth = 0.02,
  var double snapToGroundDistance = 0.2,
  var int collisionMask = 0xFFFFFFFF,
  var int maxSlideIterations = 4,
  Vector3? capsuleOffset,
  var Component3D? target,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  this
    : assert(radius > 0, 'radius must be positive'),
      assert(height >= 2 * radius, 'height must be >= 2 * radius'),
      assert(skinWidth >= 0, 'skinWidth must be non-negative');

  /// Optional offset from the character's `position` to the capsule center.
  final Vector3 capsuleOffset = capsuleOffset?.clone() ?? Vector3.zero();

  /// Whether the character rests on walkable ground (`slope <=
  /// maxSlopeAngleRad`) after the latest [moveAndSlide].
  bool isGrounded = false;

  /// World-space surface normal of the ground under the character.
  final Vector3 groundNormal = upAxis.unitVector;

  /// Actual achieved velocity `(newPosition - oldPosition) / dt` after sliding,
  /// step-up, and cliff blocking.
  final Vector3 resolvedVelocity = Vector3.zero();

  final Vector3 _up = Vector3.zero();
  final Vector3 _startPos = Vector3.zero();
  final Vector3 _currOrigin = Vector3.zero();
  final Vector3 _remaining = Vector3.zero();
  final Vector3 _horizRem = Vector3.zero();
  final Vector3 _wallNormal = Vector3.zero();
  final Vector3 _probeDelta = Vector3.zero();
  final Vector3 _liftOrigin = Vector3.zero();
  final Vector3 _forwardOrigin = Vector3.zero();
  final Matrix4 _depenMat = Matrix4.identity();

  Component3D _resolveHost() {
    final explicit = target;
    if (explicit != null) {
      return explicit;
    }
    final p = parent;
    if (p is Component3D) {
      return p;
    }
    throw StateError(
      'KinematicCharacterController3D must either be added as a child of a '
      'Component3D or have an explicit target Component3D assigned.',
    );
  }

  World3D? _resolveWorld(Component3D host, World3D? explicitWorld) {
    if (explicitWorld != null) {
      return explicitWorld;
    }
    for (final ancestor in host.ancestors()) {
      if (ancestor is World3D) {
        return ancestor;
      }
    }
    return null;
  }

  /// Sweeps and slides the character along `velocity * dt`, updating the host
  /// [Component3D.position], [isGrounded], [groundNormal], and
  /// [resolvedVelocity].
  void moveAndSlide(
    Vector3 velocity,
    double dt, {
    CollisionSystem3D? collisionSystem,
    Iterable<Object3D>? staticGeometry,
    World3D? world,
  }) {
    final host = _resolveHost();
    if (dt <= 0.0) {
      resolvedVelocity.setZero();
      return;
    }

    upAxis.writeUnitVector(_up);
    final resolvedWorld = _resolveWorld(host, world);
    final minWalkableCos = math.cos(maxSlopeAngleRad);
    final wasGrounded = isGrounded;

    _startPos.setFrom(host.position);
    _currOrigin
      ..setFrom(_startPos)
      ..add(capsuleOffset);

    bool filterSelf(Component3D candidate) {
      if (identical(candidate, host)) {
        return false;
      }
      for (final anc in candidate.ancestors()) {
        if (identical(anc, host)) {
          return false;
        }
      }
      return true;
    }

    // 1. Depenetrate any deep initial overlaps so character never gets wedged.
    _depenetrate(
      collisionSystem: collisionSystem,
      staticGeometry: staticGeometry,
      filter: filterSelf,
    );

    _remaining
      ..setFrom(velocity)
      ..scale(dt);

    final velUp = velocity.dot(_up);
    final jumpingUp = velUp > 0.05;
    var groundedNow = false;
    var hitWallNormalValid = false;
    final prevBlockNormal = Vector3.zero();

    // 2. Iterative sweep-and-slide loop.
    for (var iter = 0; iter < maxSlideIterations; iter++) {
      final remLen = _remaining.length;
      if (remLen <= 1e-6) {
        break;
      }

      final hit = ShapeCast3D.capsuleCast(
        origin: _currOrigin,
        radius: radius,
        height: height,
        axis: upAxis,
        delta: _remaining,
        collisionSystem: collisionSystem,
        world: resolvedWorld,
        staticGeometry: staticGeometry,
        collisionMask: collisionMask,
        filter: filterSelf,
      );

      if (hit == null) {
        _currOrigin.add(_remaining);
        _remaining.setZero();
        break;
      }

      // Advance safely up to `hit.distance - skinWidth`.
      final safeDist = math.max(0.0, hit.distance - skinWidth);
      if (safeDist > 0.0 && remLen > 1e-9) {
        final frac = (safeDist / remLen).clamp(0.0, 1.0);
        _currOrigin.addScaled(_remaining, frac);
        _remaining.scale(1.0 - frac);
      }

      final n = hit.normal;
      final cosSlope = n.dot(_up);
      final walkable = cosSlope >= minWalkableCos;

      if (walkable) {
        groundedNow = true;
        groundNormal.setFrom(n);

        // Absorb downward gravity on walkable ground and redirect horizontal
        // locomotion cleanly along the walkable tangent plane.
        final rUp = _remaining.dot(_up);
        if (rUp <= 0.0 && cosSlope > 1e-4) {
          _horizRem
            ..setFrom(_remaining)
            ..addScaled(_up, -rUp);
          final hLen = _horizRem.length;
          if (hLen <= 1e-7) {
            _remaining.setZero();
          } else {
            final slopeDeltaUp = -_horizRem.dot(n) / cosSlope;
            _remaining
              ..setFrom(_horizRem)
              ..addScaled(_up, slopeDeltaUp);
            final sLen = _remaining.length;
            if (sLen > hLen && sLen > 1e-7) {
              _remaining.scale(hLen / sLen);
            }
          }
        } else {
          final into = _remaining.dot(n);
          if (into < 0.0) {
            _remaining.addScaled(n, -into);
          }
        }
        continue;
      }

      // Non-walkable obstacle (wall or steep cliff `> maxSlopeAngleRad`).
      // Attempt automatic stair / ledge step-up when moving horizontally!
      final remUp = _remaining.dot(_up);
      _horizRem
        ..setFrom(_remaining)
        ..addScaled(_up, -remUp);
      final horizLen = _horizRem.length;

      if (stepOffset > 0.0 &&
          horizLen > 1e-5 &&
          (wasGrounded || groundedNow || velUp <= 0.05) &&
          _tryStepUp(
            horizRemaining: _horizRem,
            minWalkableCos: minWalkableCos,
            collisionSystem: collisionSystem,
            world: resolvedWorld,
            staticGeometry: staticGeometry,
            filter: filterSelf,
          )) {
        groundedNow = true;
        // Preserve any downward component already settled by step-down.
        _remaining.setZero();
        break;
      }

      // Block upward climbing on steep cliffs (`0 < cosSlope < minWalkableCos`)
      // by projecting horizontal push against the horizontalized wall normal!
      _wallNormal
        ..setFrom(n)
        ..addScaled(_up, -cosSlope);
      final wallLen = _wallNormal.length;
      if (wallLen > 1e-6 && cosSlope > -0.05) {
        _wallNormal.scale(1.0 / wallLen);
      } else {
        _wallNormal.setFrom(n);
      }

      final intoWall = _remaining.dot(_wallNormal);
      if (intoWall < 0.0) {
        _remaining.addScaled(_wallNormal, -intoWall);
      }
      // Also prevent any residual penetration into the true plane normal when
      // descending onto a steep slope (let gravity slide DOWN a steep cliff,
      // never UP).
      final intoTrue = _remaining.dot(n);
      if (intoTrue < 0.0) {
        final candidate = _remaining - n * intoTrue;
        if (candidate.dot(_up) <= math.max(0.0, remUp) + 1e-6) {
          _remaining.setFrom(candidate);
        } else {
          // Strip upward climb completely.
          final hInto = _horizRem.dot(_wallNormal);
          if (hInto < 0.0) {
            _horizRem.addScaled(_wallNormal, -hInto);
          }
          _remaining
            ..setFrom(_horizRem)
            ..addScaled(_up, math.min(0.0, remUp));
        }
      }

      // Two-wall corner crease stop to prevent ping-ponging in acute corners.
      if (hitWallNormalValid && prevBlockNormal.dot(_wallNormal) < 0.98) {
        final crease = prevBlockNormal.cross(_wallNormal);
        final cLen = crease.length;
        if (cLen > 1e-6) {
          crease.scale(1.0 / cLen);
          final along = _remaining.dot(crease);
          _remaining
            ..setFrom(crease)
            ..scale(along);
          // Never allow corner crease to push upward up a steep V-chute.
          final cUp = _remaining.dot(_up);
          if (cUp > math.max(0.0, remUp)) {
            _remaining.addScaled(_up, -cUp);
          }
        } else {
          _remaining.setZero();
        }
      }
      prevBlockNormal.setFrom(_wallNormal);
      hitWallNormalValid = true;
    }

    // 3. Ground probe & snap-to-ground (`snapToGroundDistance` when previously
    // grounded and not jumping upward).
    if (!jumpingUp) {
      final probeDist =
          (wasGrounded ? snapToGroundDistance : skinWidth * 2.0) + skinWidth;
      if (probeDist > 0.0) {
        _probeDelta
          ..setFrom(_up)
          ..scale(-probeDist);
        final downHit = ShapeCast3D.capsuleCast(
          origin: _currOrigin,
          radius: radius,
          height: height,
          axis: upAxis,
          delta: _probeDelta,
          collisionSystem: collisionSystem,
          world: resolvedWorld,
          staticGeometry: staticGeometry,
          collisionMask: collisionMask,
          filter: filterSelf,
        );
        if (downHit != null && downHit.normal.dot(_up) >= minWalkableCos) {
          if (wasGrounded ||
              groundedNow ||
              downHit.distance <= skinWidth * 2.5 + 1e-4) {
            final snap = math.max(0.0, downHit.distance - skinWidth);
            _currOrigin.addScaled(_up, -snap);
            groundedNow = true;
            groundNormal.setFrom(downHit.normal);
          }
        }
      }
    }

    isGrounded = groundedNow;
    if (!isGrounded) {
      groundNormal.setFrom(_up);
    }

    final newPosX = _currOrigin.x - capsuleOffset.x;
    final newPosY = _currOrigin.y - capsuleOffset.y;
    final newPosZ = _currOrigin.z - capsuleOffset.z;
    final invDt = 1.0 / dt;
    resolvedVelocity.setValues(
      (newPosX - _startPos.x) * invDt,
      (newPosY - _startPos.y) * invDt,
      (newPosZ - _startPos.z) * invDt,
    );
    host.position.setValues(newPosX, newPosY, newPosZ);
  }

  bool _tryStepUp({
    required Vector3 horizRemaining,
    required double minWalkableCos,
    required CollisionSystem3D? collisionSystem,
    required World3D? world,
    required Iterable<Object3D>? staticGeometry,
    required bool Function(Component3D) filter,
  }) {
    // 1. Sweep UP by `stepOffset + skinWidth`.
    final targetLift = stepOffset + skinWidth;
    _probeDelta
      ..setFrom(_up)
      ..scale(targetLift);
    final upHit = ShapeCast3D.capsuleCast(
      origin: _currOrigin,
      radius: radius,
      height: height,
      axis: upAxis,
      delta: _probeDelta,
      collisionSystem: collisionSystem,
      world: world,
      staticGeometry: staticGeometry,
      collisionMask: collisionMask,
      filter: filter,
    );
    final actualLift = upHit == null
        ? targetLift
        : math.max(0.0, upHit.distance - skinWidth);
    if (actualLift <= 1e-4) {
      return false;
    }

    _liftOrigin
      ..setFrom(_currOrigin)
      ..addScaled(_up, actualLift);

    // 2. Sweep FORWARD from lifted height along `horizRemaining` (ensuring at
    // least a minimal forward lip clearance probe onto the step tread).
    final horizLen = horizRemaining.length;
    final minLip = math.max(horizLen, skinWidth * 2.5);
    _probeDelta
      ..setFrom(horizRemaining)
      ..scale(minLip / horizLen);

    final fwdHit = ShapeCast3D.capsuleCast(
      origin: _liftOrigin,
      radius: radius,
      height: height,
      axis: upAxis,
      delta: _probeDelta,
      collisionSystem: collisionSystem,
      world: world,
      staticGeometry: staticGeometry,
      collisionMask: collisionMask,
      filter: filter,
    );

    final maxFwdAllowed = fwdHit == null
        ? minLip
        : math.max(0.0, fwdHit.distance - skinWidth);
    if (maxFwdAllowed <= skinWidth * 1.2) {
      return false;
    }
    final actualFwd = math.min(horizLen, maxFwdAllowed);

    _forwardOrigin
      ..setFrom(_liftOrigin)
      ..addScaled(horizRemaining, actualFwd / horizLen);

    // 3. Sweep DOWN onto the step tread.
    final downSweep = actualLift + skinWidth * 2.0;
    _probeDelta
      ..setFrom(_up)
      ..scale(-downSweep);
    final downHit = ShapeCast3D.capsuleCast(
      origin: _forwardOrigin,
      radius: radius,
      height: height,
      axis: upAxis,
      delta: _probeDelta,
      collisionSystem: collisionSystem,
      world: world,
      staticGeometry: staticGeometry,
      collisionMask: collisionMask,
      filter: filter,
    );
    if (downHit == null) {
      return false;
    }

    var resolvedTreadNormal = downHit.normal;
    if (resolvedTreadNormal.dot(_up) < minWalkableCos) {
      // A capsule's rounded bottom cap grazing a sharp 90-deg stair lip
      // yields a tilted radial cap normal even when the tread itself is flat.
      // Probe the actual tread face normal just past the lip contact point!
      final invH = 1.0 / horizLen;
      final treadRay = Ray.originDirection(
        Vector3(
          downHit.point.x + horizRemaining.x * invH * 0.02 + _up.x * 0.08,
          downHit.point.y + horizRemaining.y * invH * 0.02 + _up.y * 0.08,
          downHit.point.z + horizRemaining.z * invH * 0.02 + _up.z * 0.08,
        ),
        Vector3(-_up.x, -_up.y, -_up.z),
      );
      Vector3? sampledNormal;
      var bestDist = 0.2;
      if (collisionSystem != null) {
        final cHit = collisionSystem.raycastColliders(
          treadRay,
          maxDistance: bestDist,
          collisionMask: collisionMask,
          includeTriggers: false,
          filter: (c) => filter(c) && filter(c.hostComponent),
        );
        if (cHit != null) {
          bestDist = cHit.distance;
          sampledNormal = cHit.normal;
        }
      }
      if (staticGeometry != null) {
        for (final obj in staticGeometry) {
          if (!filter(obj)) {
            continue;
          }
          final mHit = obj.raycast(treadRay, maxDistance: bestDist);
          if (mHit != null && mHit.distance < bestDist) {
            bestDist = mHit.distance;
            sampledNormal = mHit.worldNormal;
          }
        }
      }
      if (world != null) {
        final wHit = world.raycast(
          treadRay,
          maxDistance: bestDist,
          filter: filter,
        );
        if (wHit != null) {
          sampledNormal = wHit.worldNormal;
        }
      }
      if (sampledNormal == null || sampledNormal.dot(_up) < minWalkableCos) {
        return false;
      }
      resolvedTreadNormal = sampledNormal;
    }

    final drop = math.max(0.0, downHit.distance - skinWidth);
    final netClimb = actualLift - drop;
    if (netClimb < -skinWidth || netClimb > stepOffset + skinWidth) {
      return false;
    }

    _currOrigin
      ..setFrom(_forwardOrigin)
      ..addScaled(_up, -drop);
    groundNormal.setFrom(resolvedTreadNormal);
    return true;
  }

  void _depenetrate({
    required CollisionSystem3D? collisionSystem,
    required Iterable<Object3D>? staticGeometry,
    required bool Function(Component3D) filter,
  }) {
    if (collisionSystem == null && staticGeometry == null) {
      return;
    }
    final cap = CapsuleShape3D(radius: radius, height: height, axis: upAxis);

    for (var pass = 0; pass < 2; pass++) {
      _depenMat.setIdentity();
      _depenMat.setTranslation(_currOrigin);
      var moved = false;

      if (collisionSystem != null) {
        final overlaps = collisionSystem.overlapShape(
          cap,
          _depenMat,
          collisionMask: collisionMask,
          includeTriggers: false,
          filter: (c) => filter(c) && filter(c.hostComponent),
        );
        for (final (_, manifold) in overlaps) {
          if (manifold.penetrationDepth > 1e-4) {
            _currOrigin.addScaled(
              manifold.normal,
              -(manifold.penetrationDepth + skinWidth * 0.25),
            );
            _depenMat.setTranslation(_currOrigin);
            moved = true;
          }
        }
      }

      if (staticGeometry != null) {
        for (final obj in staticGeometry) {
          if (!filter(obj) || obj is! MeshComponent) {
            continue;
          }
          for (final surface in obj.mesh.surfaces) {
            final m = Narrowphase3D.intersectShapeWithSurfaceBvh(
              cap,
              _depenMat,
              surface,
              obj.worldTransformMatrix,
            );
            if (m != null && m.penetrationDepth > 1e-4) {
              _currOrigin.addScaled(
                m.normal,
                -(m.penetrationDepth + skinWidth * 0.25),
              );
              _depenMat.setTranslation(_currOrigin);
              moved = true;
            }
          }
        }
      }

      if (!moved) {
        break;
      }
    }
  }
}
