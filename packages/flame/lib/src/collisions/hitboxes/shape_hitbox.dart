import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/shape_intersections.dart'
    as intersection_system;
import 'package:meta/meta.dart';

/// A [ShapeHitbox] turns a [ShapeComponent] into a [Hitbox].
/// It is currently used by [CircleHitbox], [RectangleHitbox] and
/// [PolygonHitbox].
mixin ShapeHitbox on ShapeComponent implements Hitbox<ShapeHitbox> {
  @internal
  final collisionTypeNotifier = CollisionTypeNotifier(CollisionType.active);

  set collisionType(CollisionType type) {
    if (collisionTypeNotifier.value == type) {
      return;
    }
    collisionTypeNotifier.value = type;
  }

  @override
  CollisionType get collisionType => collisionTypeNotifier.value;

  /// Whether the hitbox is allowed to collide with another hitbox that is
  /// added to the same parent.
  bool allowSiblingCollision = false;

  @override
  Aabb2 get aabb => _validAabb ? _aabb : _recalculateAabb();
  final Aabb2 _aabb = Aabb2();
  bool _validAabb = false;

  @override
  Set<ShapeHitbox> get activeCollisions => _activeCollisions ??= {};
  Set<ShapeHitbox>? _activeCollisions;

  @override
  bool get isColliding {
    return _activeCollisions != null && _activeCollisions!.isNotEmpty;
  }

  @override
  bool collidingWith(Hitbox other) {
    return _activeCollisions != null && activeCollisions.contains(other);
  }

  CollisionDetection? _collisionDetection;
  final List<Transform2D> _transformAncestors = [];
  late Function() _transformListener;

  @internal
  Function()? onAabbChanged;

  final Vector2 _halfExtents = Vector2.zero();
  static const double _extentEpsilon = 0.000000000000001;
  final Matrix3 _rotationMatrix = Matrix3.zero();

  @override
  bool renderShape = false;

  late PositionComponent _hitboxParent;
  PositionComponent get hitboxParent => _hitboxParent;
  void Function()? _parentSizeListener;
  @protected
  bool shouldFillParent = false;

  @override
  void onMount() {
    super.onMount();
    _hitboxParent = ancestors().firstWhere(
      (c) => c is PositionComponent && c is! CompositeHitbox,
      orElse: () {
        throw StateError('A ShapeHitbox needs a PositionComponent ancestor');
      },
    ) as PositionComponent;

    _transformListener = () {
      _validAabb = false;
      onAabbChanged?.call();
    };
    ancestors(includeSelf: true).whereType<PositionComponent>().forEach((c) {
      _transformAncestors.add(c.transform);
      c.transform.addListener(_transformListener);
    });

    if (shouldFillParent) {
      _parentSizeListener = () {
        size = hitboxParent.size;
        fillParent();
      };
      _parentSizeListener?.call();
      hitboxParent.size.addListener(_parentSizeListener!);
    }

    // This should be placed after the hitbox parent listener
    // since the correct hitbox size is required by the QuadTree.
    final parent = findParent<HasCollisionDetection>();
    if (parent is HasCollisionDetection) {
      _collisionDetection = parent.collisionDetection;
      _collisionDetection?.add(this);
    }
  }

  @override
  void onRemove() {
    if (_parentSizeListener != null) {
      hitboxParent.size.removeListener(_parentSizeListener!);
    }
    _transformAncestors.forEach((t) => t.removeListener(_transformListener));
    _collisionDetection?.remove(this);
    super.onRemove();
  }

  /// Checks whether the [ShapeHitbox] contains the [point], where [point] is
  /// a position in the global coordinate system of your game.
  @override
  bool containsPoint(Vector2 point) {
    return _possiblyContainsPoint(point) && super.containsPoint(point);
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  bool _possiblyContainsPoint(Vector2 point) {
    return aabb.containsVector2(point);
  }

  /// Where this [ShapeComponent] has intersection points with another shape
  @override
  Set<Vector2> intersections(Hitbox other) {
    assert(
      other is ShapeComponent,
      'The intersection can only be performed between shapes',
    );
    return intersection_system.intersections(this, other as ShapeComponent);
  }

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  @override
  bool possiblyIntersects(ShapeHitbox other) {
    final collisionAllowed =
        allowSiblingCollision || hitboxParent != other.hitboxParent;
    return collisionAllowed && aabb.intersectsWithAabb2(other.aabb);
  }

  /// Returns information about how the ray intersects the shape.
  ///
  /// If you are only interested in the intersection point use
  /// [RaycastResult.intersectionPoint] of the result.
  RaycastResult<ShapeHitbox>? rayIntersection(
    Ray2 ray, {
    RaycastResult<ShapeHitbox>? out,
  });

  /// This determines how the shape should scale if it should try to fill its
  /// parents boundaries.
  void fillParent();

  Aabb2 _recalculateAabb() {
    final size = absoluteScaledSize;
    // This has double.minPositive since a point on the edge of the AABB is
    // currently counted as outside.
    _halfExtents.setValues(
      size.x / 2 + _extentEpsilon,
      size.y / 2 + _extentEpsilon,
    );
    _rotationMatrix.setRotationZ(absoluteAngle);
    _validAabb = true;
    return _aabb
      ..setCenterAndHalfExtents(absoluteCenter, _halfExtents)
      ..rotate(_rotationMatrix);
  }

  //#region CollisionCallbacks methods

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    onCollisionCallback?.call(intersectionPoints, other);
    if (hitboxParent is CollisionCallbacks) {
      (hitboxParent as CollisionCallbacks).onCollision(
        intersectionPoints,
        other.hitboxParent,
      );
    }
  }

  @override
  @mustCallSuper
  void onCollisionStart(Set<Vector2> intersectionPoints, ShapeHitbox other) {
    activeCollisions.add(other);
    onCollisionStartCallback?.call(intersectionPoints, other);
    if (hitboxParent is CollisionCallbacks) {
      (hitboxParent as CollisionCallbacks).onCollisionStart(
        intersectionPoints,
        other.hitboxParent,
      );
    }
  }

  @override
  @mustCallSuper
  void onCollisionEnd(ShapeHitbox other) {
    activeCollisions.remove(other);
    onCollisionEndCallback?.call(other);
    if (hitboxParent is CollisionCallbacks) {
      (hitboxParent as CollisionCallbacks).onCollisionEnd(other.hitboxParent);
    }
  }

  /// Defines whether the [other] component should be able to collide with
  /// this component.
  ///
  /// If the [hitboxParent] is not `CollisionCallbacks` but `PositionComponent`,
  /// there is no [CollisionCallbacks.onComponentTypeCheck] in that component.
  /// As a result, it will always be able to collide with all other types.
  @override
  @mustCallSuper
  bool onComponentTypeCheck(PositionComponent other) {
    final otherHitboxParent = (other as ShapeHitbox).hitboxParent;

    final thisCanCollideWithOther = (hitboxParent is! CollisionCallbacks) ||
        (hitboxParent as CollisionCallbacks)
            .onComponentTypeCheck(otherHitboxParent);

    final otherCanCollideWithThis =
        (otherHitboxParent is! CollisionCallbacks) ||
            (otherHitboxParent as CollisionCallbacks)
                .onComponentTypeCheck(hitboxParent);

    return thisCanCollideWithOther && otherCanCollideWithThis;
  }

  @override
  CollisionCallback<ShapeHitbox>? onCollisionCallback;

  @override
  CollisionCallback<ShapeHitbox>? onCollisionStartCallback;

  @override
  CollisionEndCallback<ShapeHitbox>? onCollisionEndCallback;

  //#endregion
}
