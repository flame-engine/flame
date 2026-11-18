import 'package:flame/components.dart' show Component, HasWorldRef;
import 'package:flame_3d/camera.dart' show Ray, World3D;
import 'package:flame_3d/collisions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:meta/meta.dart';

/// Mixin on [Component3D] receiving 3D collider contact lifecycle callbacks
/// from [CollisionSystem3D].
mixin CollisionCallbacks3D on Component3D {
  /// Invoked on the step when this component's collider begins overlapping
  /// [other].
  ///
  /// `manifold.normal` points from this component's collider toward [other].
  void onCollisionStart3D(Collider3D other, CollisionManifold3D manifold) {}

  /// Invoked on every step while this component's collider continues
  /// overlapping [other].
  void onCollision3D(Collider3D other, CollisionManifold3D manifold) {}

  /// Invoked when this component's collider stops overlapping [other] (or when
  /// either collider is removed).
  void onCollisionEnd3D(Collider3D other) {}
}

/// A 3D collision volume attachable to any [Component3D] (or usable standalone
/// in a [World3D]).
class Collider3D({
  required Shape3D shape,
  Vector3? localOffset,
  var int collisionLayer = 1,
  var int collisionMask = 0xFFFFFFFF,
  var bool isTrigger = false,
  var bool isStatic = false,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  Shape3D _shape = shape;

  /// Geometric collision shape in local space.
  Shape3D get shape => _shape;
  set shape(Shape3D value) {
    if (identical(value, _shape)) {
      return;
    }
    _shape = value;
    markAabbDirty();
  }

  /// Additional local-space translation offset of [shape] relative to this
  /// component's origin.
  final Vector3 localOffset = localOffset?.clone() ?? Vector3.zero();

  final Matrix4 _colliderWorldMatrix = Matrix4.identity();
  final Aabb3 _colliderWorldAabb = Aabb3();
  final Aabb3 _localShapeAabb = Aabb3();

  /// The logical owner component of this collider: its parent [Component3D] if
  /// attached as a child, or `this` when standalone.
  Component3D get hostComponent {
    final p = parent;
    return p is Component3D ? p : this;
  }

  /// World transformation matrix of [shape], combining [worldTransformMatrix]
  /// with [localOffset].
  Matrix4 get colliderWorldMatrix {
    final w = worldTransformMatrix;
    final m = w.storage;
    final ox = localOffset.x;
    final oy = localOffset.y;
    final oz = localOffset.z;
    _colliderWorldMatrix.setFrom(w);
    if (ox != 0.0 || oy != 0.0 || oz != 0.0) {
      final out = _colliderWorldMatrix.storage;
      out[12] = m[0] * ox + m[4] * oy + m[8] * oz + m[12];
      out[13] = m[1] * ox + m[5] * oy + m[9] * oz + m[13];
      out[14] = m[2] * ox + m[6] * oy + m[10] * oz + m[14];
    }
    return _colliderWorldMatrix;
  }

  /// Computes and returns the world-space AABB of [shape] at
  /// [colliderWorldMatrix].
  Aabb3 get colliderWorldAabb {
    _shape.computeWorldAabb(colliderWorldMatrix, _colliderWorldAabb);
    return _colliderWorldAabb;
  }

  /// Returns `true` when 32-bit layer/mask filtering allows contact with
  /// [other].
  bool canCollideWith(Collider3D other) {
    if (identical(this, other) ||
        identical(hostComponent, other.hostComponent)) {
      return false;
    }
    if (isStatic && other.isStatic) {
      return false;
    }
    return (collisionLayer & other.collisionMask) != 0 &&
        (other.collisionLayer & collisionMask) != 0;
  }

  @override
  Aabb3? computeLocalAabb() {
    _shape.computeLocalAabb(out: _localShapeAabb);
    _localShapeAabb.min.add(localOffset);
    _localShapeAabb.max.add(localOffset);
    return _localShapeAabb;
  }
}

/// Sensor collider (`isTrigger: true`) firing [onEnter3D], [onStay3D], and
/// [onExit3D] callbacks without physical blocking.
class TriggerVolume3D({
  required super.shape,
  super.localOffset,
  super.collisionLayer,
  super.collisionMask,
  super.isStatic,
  super.position,
  super.scale,
  super.rotation,
  super.children,
  final void Function(Collider3D other, CollisionManifold3D manifold)?
  onEnter3D,
  final void Function(Collider3D other, CollisionManifold3D manifold)? onStay3D,
  final void Function(Collider3D other)? onExit3D,
}) extends Collider3D {
  this : super(isTrigger: true);

  /// Called when [other] enters this trigger volume.
  void handleEnter3D(Collider3D other, CollisionManifold3D manifold) {
    onEnter3D?.call(other, manifold);
  }

  /// Called each step while [other] stays inside this trigger volume.
  void handleStay3D(Collider3D other, CollisionManifold3D manifold) {
    onStay3D?.call(other, manifold);
  }

  /// Called when [other] exits this trigger volume.
  void handleExit3D(Collider3D other) {
    onExit3D?.call(other);
  }
}

/// Ray hit result returned by [CollisionSystem3D.raycastColliders].
class ColliderRayHit3D({
  required final Collider3D collider,
  required final double distance,
  required final Vector3 point,
  required final Vector3 normal,
});

/// World-level 3D collision manager running sort-and-sweep broadphase, 32-bit
/// layer/mask filtering, [Narrowphase3D] manifold generation, and start/stay/end
/// callback dispatch.
class CollisionSystem3D({
  var bool autoStep = true,
  super.priority,
}) extends Component with HasWorldRef<World3D> {
  final Set<Collider3D> _manualColliders = {};
  final List<_SweepEntry> _entries = [];
  Map<_ColliderPairKey, (Collider3D, Collider3D)> _activePairs = {};

  /// Explicitly registers [collider] for standalone or unmounted simulation.
  void register(Collider3D collider) {
    _manualColliders.add(collider);
  }

  /// Unregisters a manually registered [collider] and fires any pending end
  /// callbacks for pairs involving it.
  void unregister(Collider3D collider) {
    _manualColliders.remove(collider);
    _flushRemovedCollider(collider);
  }

  /// Collects all active colliders (both mounted in the enclosing world/parent
  /// tree and manually registered via [register]).
  List<Collider3D> collectColliders([List<Collider3D>? out]) {
    final result = out ?? <Collider3D>[];
    result.clear();
    final seen = <Collider3D>{};

    void addUnique(Collider3D c) {
      if (seen.add(c)) {
        result.add(c);
      }
    }

    for (final c in _manualColliders) {
      addUnique(c);
    }

    final root = parent;
    if (root != null) {
      void visit(Component comp) {
        if (comp is Collider3D) {
          addUnique(comp);
        }
        for (final child in comp.children) {
          visit(child);
        }
      }

      visit(root);
    }
    return result;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (autoStep) {
      step();
    }
  }

  /// Runs one broadphase + narrowphase detection pass and dispatches
  /// [CollisionCallbacks3D] and [TriggerVolume3D] events.
  void step() {
    final colliders = collectColliders(_collectedScratch);
    _entries.clear();
    for (var i = 0; i < colliders.length; i++) {
      final c = colliders[i];
      final box = c.colliderWorldAabb;
      _entries.add(
        _SweepEntry(
          collider: c,
          minX: box.min.x,
          minY: box.min.y,
          minZ: box.min.z,
          maxX: box.max.x,
          maxY: box.max.y,
          maxZ: box.max.z,
        ),
      );
    }

    // Sort-and-Sweep along the X axis.
    _entries.sort((a, b) => a.minX.compareTo(b.minX));

    final nextPairs = <_ColliderPairKey, (Collider3D, Collider3D)>{};

    for (var i = 0; i < _entries.length; i++) {
      final a = _entries[i];
      final maxX = a.maxX;
      for (var j = i + 1; j < _entries.length; j++) {
        final b = _entries[j];
        if (b.minX > maxX) {
          break;
        }
        if (a.maxY < b.minY ||
            a.minY > b.maxY ||
            a.maxZ < b.minZ ||
            a.minZ > b.maxZ) {
          continue;
        }
        if (!a.collider.canCollideWith(b.collider)) {
          continue;
        }

        // Canonical pair ordering so manifold A->B direction is deterministic.
        final swap =
            identityHashCode(a.collider) > identityHashCode(b.collider);
        final first = swap ? b.collider : a.collider;
        final second = swap ? a.collider : b.collider;

        final manifold = Narrowphase3D.test(
          first.shape,
          first.colliderWorldMatrix,
          second.shape,
          second.colliderWorldMatrix,
        );
        if (manifold == null) {
          continue;
        }

        final key = _ColliderPairKey(first, second);
        final wasActive = _activePairs.containsKey(key);
        nextPairs[key] = (first, second);

        final flipped = manifold.flipped();
        if (!wasActive) {
          _dispatchStart(first, second, manifold);
          _dispatchStart(second, first, flipped);
        } else {
          _dispatchStay(first, second, manifold);
          _dispatchStay(second, first, flipped);
        }
      }
    }

    for (final entry in _activePairs.entries) {
      if (!nextPairs.containsKey(entry.key)) {
        final (first, second) = entry.value;
        _dispatchEnd(first, second);
        _dispatchEnd(second, first);
      }
    }

    _activePairs = nextPairs;
  }

  /// Queries all colliders overlapping [shape] at [worldTransform].
  List<(Collider3D collider, CollisionManifold3D manifold)> overlapShape(
    Shape3D shape,
    Matrix4 worldTransform, {
    int collisionMask = 0xFFFFFFFF,
    bool includeTriggers = true,
    bool Function(Collider3D collider)? filter,
  }) {
    shape.computeWorldAabb(worldTransform, _queryAabb);
    final colliders = collectColliders(_collectedScratch);
    final hits = <(Collider3D, CollisionManifold3D)>[];

    for (var i = 0; i < colliders.length; i++) {
      final c = colliders[i];
      if (!includeTriggers && c.isTrigger) {
        continue;
      }
      if ((c.collisionLayer & collisionMask) == 0) {
        continue;
      }
      if (filter != null && !filter(c)) {
        continue;
      }
      final box = c.colliderWorldAabb;
      if (!_boxesOverlap(_queryAabb, box)) {
        continue;
      }
      final manifold = Narrowphase3D.test(
        shape,
        worldTransform,
        c.shape,
        c.colliderWorldMatrix,
      );
      if (manifold != null) {
        hits.add((c, manifold));
      }
    }
    return hits;
  }

  /// Casts [worldRay] against registered/mounted colliders within
  /// [maxDistance], returning the closest [ColliderRayHit3D] or `null`.
  ColliderRayHit3D? raycastColliders(
    Ray worldRay, {
    double maxDistance = double.infinity,
    int collisionMask = 0xFFFFFFFF,
    bool includeTriggers = true,
    bool Function(Collider3D collider)? filter,
  }) {
    if (!(maxDistance > 0.0)) {
      return null;
    }
    final dirLen = worldRay.direction.length;
    if (dirLen <= 1e-12) {
      return null;
    }
    _unitRay.origin.setFrom(worldRay.origin);
    _unitRay.direction
      ..setFrom(worldRay.direction)
      ..scale(1.0 / dirLen);

    final colliders = collectColliders(_collectedScratch);
    ColliderRayHit3D? best;
    var limit = maxDistance;

    for (var i = 0; i < colliders.length; i++) {
      final c = colliders[i];
      if (!includeTriggers && c.isTrigger) {
        continue;
      }
      if ((c.collisionLayer & collisionMask) == 0) {
        continue;
      }
      if (filter != null && !filter(c)) {
        continue;
      }
      final box = c.colliderWorldAabb;
      if (!_rayHitsAabb(_unitRay, box, limit)) {
        continue;
      }
      final hit = c.shape.raycast(
        _unitRay,
        c.colliderWorldMatrix,
        maxDistance: limit,
      );
      if (hit != null && hit.$1 <= limit) {
        limit = hit.$1;
        final t = hit.$1;
        best = ColliderRayHit3D(
          collider: c,
          distance: t,
          point: Vector3(
            _unitRay.origin.x + _unitRay.direction.x * t,
            _unitRay.origin.y + _unitRay.direction.y * t,
            _unitRay.origin.z + _unitRay.direction.z * t,
          ),
          normal: hit.$2,
        );
      }
    }
    return best;
  }

  void _flushRemovedCollider(Collider3D removed) {
    final toRemove = <_ColliderPairKey>[];
    for (final entry in _activePairs.entries) {
      final (first, second) = entry.value;
      if (identical(first, removed) || identical(second, removed)) {
        toRemove.add(entry.key);
        _dispatchEnd(first, second);
        _dispatchEnd(second, first);
      }
    }
    for (final k in toRemove) {
      _activePairs.remove(k);
    }
  }

  static void _dispatchStart(
    Collider3D receiver,
    Collider3D other,
    CollisionManifold3D manifold,
  ) {
    if (receiver is TriggerVolume3D) {
      receiver.handleEnter3D(other, manifold);
    }
    if (receiver case final CollisionCallbacks3D cb) {
      cb.onCollisionStart3D(other, manifold);
    }
    final p = receiver.parent;
    if (p is CollisionCallbacks3D && !identical(p, receiver)) {
      p.onCollisionStart3D(other, manifold);
    }
  }

  static void _dispatchStay(
    Collider3D receiver,
    Collider3D other,
    CollisionManifold3D manifold,
  ) {
    if (receiver is TriggerVolume3D) {
      receiver.handleStay3D(other, manifold);
    }
    if (receiver case final CollisionCallbacks3D cb) {
      cb.onCollision3D(other, manifold);
    }
    final p = receiver.parent;
    if (p is CollisionCallbacks3D && !identical(p, receiver)) {
      p.onCollision3D(other, manifold);
    }
  }

  static void _dispatchEnd(Collider3D receiver, Collider3D other) {
    if (receiver is TriggerVolume3D) {
      receiver.handleExit3D(other);
    }
    if (receiver case final CollisionCallbacks3D cb) {
      cb.onCollisionEnd3D(other);
    }
    final p = receiver.parent;
    if (p is CollisionCallbacks3D && !identical(p, receiver)) {
      p.onCollisionEnd3D(other);
    }
  }

  static bool _boxesOverlap(Aabb3 a, Aabb3 b) {
    return a.min.x <= b.max.x &&
        a.max.x >= b.min.x &&
        a.min.y <= b.max.y &&
        a.max.y >= b.min.y &&
        a.min.z <= b.max.z &&
        a.max.z >= b.min.z;
  }

  static bool _rayHitsAabb(Ray ray, Aabb3 box, double maxT) {
    var tMin = 0.0;
    var tMax = maxT;

    bool slab(double o, double d, double lo, double hi) {
      final minV = lo - 1e-5;
      final maxV = hi + 1e-5;
      if (d.abs() < 1e-12) {
        return o >= minV && o <= maxV;
      }
      final inv = 1.0 / d;
      var t1 = (minV - o) * inv;
      var t2 = (maxV - o) * inv;
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
      return tMin <= tMax;
    }

    return slab(ray.origin.x, ray.direction.x, box.min.x, box.max.x) &&
        slab(ray.origin.y, ray.direction.y, box.min.y, box.max.y) &&
        slab(ray.origin.z, ray.direction.z, box.min.z, box.max.z);
  }

  final List<Collider3D> _collectedScratch = [];
  final Aabb3 _queryAabb = Aabb3();
  final Ray _unitRay = Ray();
}

class _SweepEntry({
  required final Collider3D collider,
  required final double minX,
  required final double minY,
  required final double minZ,
  required final double maxX,
  required final double maxY,
  required final double maxZ,
});

@immutable
class const _ColliderPairKey(this.a, this.b) {
  final Collider3D a;
  final Collider3D b;

  @override
  bool operator ==(Object other) {
    return other is _ColliderPairKey &&
        ((identical(a, other.a) && identical(b, other.b)) ||
            (identical(a, other.b) && identical(b, other.a)));
  }

  @override
  int get hashCode => identityHashCode(a) ^ identityHashCode(b);
}
