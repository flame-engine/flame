import 'package:meta/meta.dart';

import '../../../collision_detection.dart';
import '../../../components.dart';
import '../../../game.dart';
import '../../../geometry.dart';
import '../../geometry/shape_intersections.dart' as intersection_system;

/// A [HitboxShape] turns a [ShapeComponent] into a [Hitbox].
/// It is currently used by [HitboxCircle], [HitboxRectangle] and
/// [HitboxPolygon].
mixin HitboxShape on ShapeComponent implements Hitbox<HitboxShape> {
  @override
  CollidableType collidableType = CollidableType.active;

  /// Whether the hitbox is allowed to collide with another hitbox that is
  /// added to the same parent.
  bool allowSiblingCollision = false;

  @override
  Aabb2 get aabb => _validAabb ? _aabb : _recalculateAabb();
  final Aabb2 _aabb = Aabb2();
  bool _validAabb = false;

  @override
  Set<HitboxShape> get activeCollisions => _activeCollisions ??= {};
  Set<HitboxShape>? _activeCollisions;

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

  final Vector2 _halfExtents = Vector2.zero();
  final Matrix3 _rotationMatrix = Matrix3.zero();

  @override
  bool get renderShape => _renderShape || debugMode;
  @override
  set renderShape(bool shouldRender) => _renderShape = shouldRender;
  bool _renderShape = false;

  @protected
  late PositionComponent hitboxParent;
  void Function()? _parentSizeListener;
  @protected
  bool shouldFillParent = false;

  @override
  void onMount() {
    super.onMount();
    hitboxParent = ancestors().firstWhere(
      (c) => c is PositionComponent,
      orElse: () {
        throw StateError('A HitboxShape needs a PositionComponent ancestor');
      },
    ) as PositionComponent;

    _transformListener = () => _validAabb = false;
    ancestors(includeSelf: true).whereType<PositionComponent>().forEach((c) {
      _transformAncestors.add(c.transform);
      c.transform.addListener(_transformListener);
    });

    final parentGame = findParent<FlameGame>();
    if (parentGame is HasCollisionDetection) {
      _collisionDetection = parentGame.collisionDetection;
      _collisionDetection?.add(this);
    }

    if (shouldFillParent) {
      _parentSizeListener = () {
        size = hitboxParent.size;
        fillParent();
      };
      _parentSizeListener?.call();
      hitboxParent.size.addListener(_parentSizeListener!);
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

  /// Checks whether the [HitboxShape] contains the [point].
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
  bool possiblyIntersects(HitboxShape other) {
    final collisionAllowed =
        allowSiblingCollision || hitboxParent != other.hitboxParent;
    return collisionAllowed && aabb.intersectsWithAabb2(other.aabb);
  }

  /// This determines how the shape should scale if it should try to fill its
  /// parents boundaries.
  void fillParent();

  Aabb2 _recalculateAabb() {
    final size = absoluteScaledSize;
    // This has +1 since a point on the edge of the bounding box is currently
    // counted as outside.
    _halfExtents.setValues(size.x + 1, size.y + 1);
    _rotationMatrix.setRotationZ(absoluteAngle);
    _validAabb = true;
    return _aabb
      ..setCenterAndHalfExtents(absoluteCenter, _halfExtents)
      ..rotate(_rotationMatrix);
  }

  //#region CollisionCallbacks methods

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, HitboxShape other) {
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
  void onCollisionStart(Set<Vector2> intersectionPoints, HitboxShape other) {
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
  void onCollisionEnd(HitboxShape other) {
    activeCollisions.remove(other);
    onCollisionEndCallback?.call(other);
    if (hitboxParent is CollisionCallbacks) {
      (hitboxParent as CollisionCallbacks).onCollisionEnd(other.hitboxParent);
    }
  }

  @override
  CollisionCallback<HitboxShape>? onCollisionCallback;

  @override
  CollisionCallback<HitboxShape>? onCollisionStartCallback;

  @override
  CollisionEndCallback<HitboxShape>? onCollisionEndCallback;

  //#endregion
}
