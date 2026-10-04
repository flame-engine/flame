import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:meta/meta.dart';

/// The default implementation of [CollisionDetection].
/// Checks whether any [ShapeHitbox]s in [items] collide with each other and
/// calls their callback methods accordingly.
///
/// By default the [Sweep] broadphase is used, this can be configured by
/// passing in another [Broadphase] to the constructor.
class StandardCollisionDetection<B extends Broadphase<ShapeHitbox>>({
  B? broadphase,
}) extends CollisionDetection<ShapeHitbox, B> {
  this : super(broadphase: broadphase ?? Sweep<ShapeHitbox>() as B);

  /// Check what the intersection points of two collidables are,
  /// returns an empty list if there are no intersections.
  @override
  List<Vector2> intersections(
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    return hitboxA.intersections(hitboxB);
  }

  /// Calls the two colliding hitboxes when they first starts to collide.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollisionStart(
    List<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollisionStart(intersectionPoints, hitboxB);
    hitboxB.onCollisionStart(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes every tick when they are colliding.
  /// They are called with the [intersectionPoints] and instances of each other,
  /// so that they can determine what hitbox (and what
  /// [ShapeHitbox.hitboxParent] that they have collided with.
  @override
  void handleCollision(
    List<Vector2> intersectionPoints,
    ShapeHitbox hitboxA,
    ShapeHitbox hitboxB,
  ) {
    hitboxA.onCollision(intersectionPoints, hitboxB);
    hitboxB.onCollision(intersectionPoints, hitboxA);
  }

  /// Calls the two colliding hitboxes once when two hitboxes have stopped
  /// colliding.
  /// They are called with instances of each other, so that they can determine
  /// what hitbox (and what [ShapeHitbox.hitboxParent] that they have stopped
  /// colliding with.
  @override
  void handleCollisionEnd(ShapeHitbox hitboxA, ShapeHitbox hitboxB) {
    hitboxA.onCollisionEnd(hitboxB);
    hitboxB.onCollisionEnd(hitboxA);
  }

  static final _temporaryRaycastResult = RaycastResult<ShapeHitbox>();

  /// The hitboxes that a ray may reach, ordered by the distance at which the
  /// ray enters their boxes. They are kept between the rays of this instance,
  /// to not allocate for each ray.
  final _candidates = _RaycastCandidates();

  /// Whether a [raycast] of this instance is running, so that one started
  /// from inside of it, by a hitbox filter or by a
  /// [ShapeHitbox.rayIntersection], does not take over its [_candidates].
  bool _isCasting = false;

  /// The number of hitboxes that are still referenced by the candidates of
  /// the last [raycast], which is 0 once it has returned.
  @visibleForTesting
  int get retainedRaycastCandidates => _candidates.retained;

  /// Casts the [ray] and returns the nearest hit, if any.
  ///
  /// The hitboxes are visited from the nearest to the farthest, by the point
  /// where the ray enters their bounding boxes, and the search stops as soon
  /// as the best hit so far is nearer than the next hitbox, so that most
  /// hitboxes never have their [ShapeHitbox.rayIntersection] called. Between
  /// hitboxes hit at exactly the same distance, the one whose box is entered
  /// first wins.
  ///
  /// Hitboxes that rays should go through, like trigger zones, are best left
  /// out with [hitboxFilter], which skips them before any work, rather than
  /// with a [ShapeHitbox.rayIntersection] that always returns `null`, as such
  /// hitboxes still have to be ordered.
  @override
  RaycastResult<ShapeHitbox>? raycast(
    Ray2 ray, {
    double? maxDistance,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    RaycastResult<ShapeHitbox>? out,
  }) {
    var finalResult = out?..reset();
    final limit = maxDistance ?? double.infinity;
    final isNested = _isCasting;
    final candidates = isNested ? _RaycastCandidates() : _candidates;
    _isCasting = true;
    try {
      for (final item in items) {
        if (!_isCandidate(item, hitboxFilter, ignoreHitboxes)) {
          continue;
        }
        final entry = ray.entryDistanceToAabb2(item.aabb);
        if (entry < 0 || entry > limit) {
          continue;
        }
        candidates.add(entry, item);
      }
      candidates.order();
      // Takes the hitboxes out from the nearest to the farthest. Most of the
      // time the loop ends after a few, so the rest are never ordered.
      while (candidates.isNotEmpty) {
        // A hit can not be nearer than the entry point to its box.
        if ((finalResult?.isActive ?? false) &&
            finalResult!.distance! <= candidates.nearestDistance) {
          break;
        }
        final hitbox = candidates.removeNearest();
        final currentResult = hitbox.rayIntersection(
          ray,
          out: _temporaryRaycastResult,
        );
        finalResult = _nearer(finalResult, currentResult, limit);
      }
    } finally {
      // Do not keep the hitboxes alive through the candidates, also if one of
      // the callbacks throws.
      candidates.clear();
      if (!isNested) {
        _isCasting = false;
      }
    }
    return (finalResult?.isActive ?? false) ? finalResult : null;
  }

  /// Whether a ray may hit [hitbox], by the `hitboxFilter` and the
  /// `ignoreHitboxes` arguments of [raycast].
  @pragma('vm:prefer-inline')
  static bool _isCandidate(
    ShapeHitbox hitbox,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
  ) {
    if (ignoreHitboxes?.contains(hitbox) ?? false) {
      return false;
    }
    return hitboxFilter == null || hitboxFilter(hitbox);
  }

  /// The nearer of [best], the best hit so far, and [current], a hit that is
  /// only taken when it is not farther than [maxDistance]. It is written into
  /// [best] when there is one, and otherwise cloned, as [current] is reused.
  @pragma('vm:prefer-inline')
  static RaycastResult<ShapeHitbox>? _nearer(
    RaycastResult<ShapeHitbox>? best,
    RaycastResult<ShapeHitbox>? current,
    double maxDistance,
  ) {
    // A positive comparison, so that a NaN distance or limit is rejected.
    if (current == null || !(current.distance! <= maxDistance)) {
      return best;
    }
    if (best == null) {
      return current.clone();
    }
    if (!best.isActive || current.distance! < best.distance!) {
      best.setFrom(current);
    }
    return best;
  }

  @override
  List<RaycastResult<ShapeHitbox>> raycastAll(
    Vector2 origin, {
    required int numberOfRays,
    double startAngle = 0,
    double sweepAngle = tau,
    double? maxDistance,
    List<Ray2>? rays,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) {
    final isFullCircle = (sweepAngle % tau).abs() < 0.0001;
    final angle = sweepAngle / (numberOfRays + (isFullCircle ? 0 : -1));
    final results = <RaycastResult<ShapeHitbox>>[];
    final direction = Vector2(1, 0);
    for (var i = 0; i < numberOfRays; i++) {
      Ray2 ray;
      if (i < (rays?.length ?? 0)) {
        ray = rays![i];
      } else {
        ray = Ray2.zero();
        rays?.add(ray);
      }
      ray.origin.setFrom(origin);
      direction
        ..setValues(0, -1)
        ..rotate(startAngle - angle * i);
      ray.direction = direction;

      RaycastResult<ShapeHitbox>? result;
      if (i < (out?.length ?? 0)) {
        result = out![i];
      } else {
        result = RaycastResult();
        out?.add(result);
      }
      result = raycast(
        ray,
        maxDistance: maxDistance,
        hitboxFilter: hitboxFilter,
        ignoreHitboxes: ignoreHitboxes,
        out: result,
      );

      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  @override
  Iterable<RaycastResult<ShapeHitbox>> raytrace(
    Ray2 ray, {
    int maxDepth = 10,
    bool Function(ShapeHitbox candidate)? hitboxFilter,
    List<ShapeHitbox>? ignoreHitboxes,
    List<RaycastResult<ShapeHitbox>>? out,
  }) sync* {
    if (out != null) {
      for (final result in out) {
        result.reset();
      }
    }
    var currentRay = ray;
    for (var i = 0; i < maxDepth; i++) {
      final hasResultObject = (out?.length ?? 0) > i;
      final storeResult = hasResultObject
          ? out![i]
          : RaycastResult<ShapeHitbox>();
      final currentResult = raycast(
        currentRay,
        hitboxFilter: hitboxFilter,
        ignoreHitboxes: ignoreHitboxes,
        out: storeResult,
      );
      if (currentResult != null) {
        currentRay = storeResult.reflectionRay!;
        if (!hasResultObject && out != null) {
          out.add(storeResult);
        }
        yield storeResult;
      } else {
        break;
      }
    }
  }
}

/// The hitboxes that a ray may reach, and the distances at which the ray
/// enters their boxes, as a binary min-heap by distance, so that the nearest
/// can be taken out first without ordering them all. It only grows, so that
/// it does not allocate for each ray when it is kept between them.
class _RaycastCandidates() {
  var _distances = Float64List(32);
  var _hitboxes = List<ShapeHitbox?>.filled(32, null);

  /// The number of candidates that have not been taken out.
  var _length = 0;

  /// The most candidates there have been since the last [clear], which is
  /// how many entries of [_hitboxes] may be set.
  var _added = 0;

  bool get isNotEmpty => _length > 0;

  /// The number of hitboxes that are still referenced.
  int get retained => _hitboxes.where((hitbox) => hitbox != null).length;

  /// Adds a candidate at the end, without keeping the order, which [order]
  /// restores for all of them at once.
  void add(double distance, ShapeHitbox hitbox) {
    if (_length == _distances.length) {
      final capacity = _length * 2;
      _distances = Float64List(capacity)..setRange(0, _length, _distances);
      _hitboxes = List<ShapeHitbox?>.filled(capacity, null)
        ..setRange(0, _length, _hitboxes);
    }
    _distances[_length] = distance;
    _hitboxes[_length] = hitbox;
    _length++;
    _added = math.max(_added, _length);
  }

  /// Orders the candidates so that the nearest is first.
  void order() {
    for (var index = (_length >> 1) - 1; index >= 0; index--) {
      _siftDown(index);
    }
  }

  /// The distance of the nearest candidate, which must exist.
  double get nearestDistance => _distances[0];

  /// Takes the nearest candidate out, which must exist.
  ShapeHitbox removeNearest() {
    final hitbox = _hitboxes[0]!;
    _length--;
    if (_length > 0) {
      _distances[0] = _distances[_length];
      _hitboxes[0] = _hitboxes[_length];
      _siftDown(0);
    }
    return hitbox;
  }

  /// Takes all of the candidates out and drops the references to them.
  void clear() {
    _hitboxes.fillRange(0, _added, null);
    _length = 0;
    _added = 0;
  }

  /// Moves the entry at [index] down until its children are not nearer.
  void _siftDown(int index) {
    final distance = _distances[index];
    final hitbox = _hitboxes[index];
    final half = _length >> 1;
    var hole = index;
    while (hole < half) {
      var child = 2 * hole + 1;
      if (child + 1 < _length && _distances[child + 1] < _distances[child]) {
        child++;
      }
      if (_distances[child] >= distance) {
        break;
      }
      _distances[hole] = _distances[child];
      _hitboxes[hole] = _hitboxes[child];
      hole = child;
    }
    _distances[hole] = distance;
    _hitboxes[hole] = hitbox;
  }
}
