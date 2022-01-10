import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../collision_detection/collision_callbacks.dart';
import '../../collision_detection/collision_detection.dart';
import '../../collision_detection/hitbox_shape.dart';

// TODO(spydon): Rename?
mixin HasHitboxes on PositionComponent implements Collidable<HasHitboxes> {
  @override
  CollidableType collidableType = CollidableType.active;

  @override
  Aabb2 get aabb => _validAabb ? _aabb : _recalculateAabb();
  final Aabb2 _aabb = Aabb2();
  bool _validAabb = false;

  @override
  Set<HasHitboxes> get activeCollisions => _activeCollisions ??= {};
  Set<HasHitboxes>? _activeCollisions;
  @override
  bool activeCollision(HasHitboxes other) {
    return _activeCollisions != null && activeCollisions.contains(other);
  }

  CollisionDetection? _collisionDetection;

  final Vector2 _halfExtents = Vector2.zero();
  final Matrix3 _rotationMatrix = Matrix3.zero();

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await super.onLoad();
    children.register<HitboxShape>();
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    ancestors(includeSelf: true).whereType<PositionComponent>().forEach((c) {
      c.transform.addListener(() => _validAabb = false);
    });

    if (this is! HitboxShape) {
      final parentGame = findParent<FlameGame>();
      if (parentGame is HasCollisionDetection) {
        _collisionDetection = parentGame.collisionDetection;
        _collisionDetection?.add(this);
      }
    }
  }

  @override
  void onRemove() {
    _collisionDetection?.remove(this);
    super.onRemove();
  }

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

  List<HasHitboxes> get hitboxes => children.query<HasHitboxes>();

  /// Checks whether the hitbox represented by the list of [HitboxShape]
  /// contains the [point].
  @override
  bool containsPoint(Vector2 point) {
    print(possiblyContainsPoint(point));
    return possiblyContainsPoint(point) &&
        hitboxes.any((hitbox) => hitbox.containsPoint(point));
  }

  //#region [CollisionCallbacks] methods

  /// Since this is a cheaper calculation than checking towards all shapes, this
  /// check can be done first to see if it even is possible that the shapes can
  /// overlap, since the shapes have to be within the size of the component.
  @override
  bool possiblyOverlapping(Collidable other) {
    return aabb.intersectsWithAabb2(other.aabb);
  }

  /// Since this is a cheaper calculation than checking towards all shapes this
  /// check can be done first to see if it even is possible that the shapes can
  /// contain the point, since the shapes have to be within the size of the
  /// component.
  @override
  bool possiblyContainsPoint(Vector2 point) {
    return aabb.containsVector2(point);
  }

  @override
  Set<Vector2> intersections(HasHitboxes other) {
    assert(
      _collisionDetection != null,
      'The parent game does not have a collision detection system',
    );
    return _collisionDetection!.intersections(this, other);
  }

  @override
  @mustCallSuper
  void onCollision(Set<Vector2> intersectionPoints, HasHitboxes other) {
    collisionCallback?.call(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionStart(Set<Vector2> intersectionPoints, HasHitboxes other) {
    activeCollisions.add(other);
    collisionStartCallback?.call(intersectionPoints, other);
  }

  @override
  @mustCallSuper
  void onCollisionEnd(HasHitboxes other) {
    activeCollisions.remove(other);
    collisionEndCallback?.call(other);
  }

  @override
  CollisionCallback<HasHitboxes>? collisionCallback;

  @override
  CollisionCallback<HasHitboxes>? collisionStartCallback;

  @override
  CollisionEndCallback<HasHitboxes>? collisionEndCallback;
  //#endregion
}
