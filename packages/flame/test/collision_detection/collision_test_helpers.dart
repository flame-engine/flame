import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';

class HasCollidablesGame extends FlameGame with HasCollisionDetection {}

final withCollidables = FlameTester(() => HasCollidablesGame());

class TestHitbox extends HitboxRectangle {
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  TestHitbox() {
    onCollisionCallback = (_, __) {
      onCollisionCounter++;
    };
    onCollisionStartCallback = (_, __) {
      startCounter++;
    };
    onCollisionEndCallback = (_) {
      endCounter++;
    };
  }
}

class TestBlock extends PositionComponent with CollisionCallbacks {
  String? name;
  final hitbox = TestHitbox();
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  TestBlock(
    Vector2 position,
    Vector2 size, {
    CollidableType type = CollidableType.active,
    bool addTestHitbox = true,
    this.name,
  }) : super(
          position: position,
          size: size,
        ) {
    children.register<HitboxShape>();
    if (addTestHitbox) {
      add(hitbox..collidableType = type);
    }
  }

  @override
  bool collidingWith(PositionComponent other) {
    return activeCollisions.contains(other);
  }

  bool collidedWithExactly(List<CollisionCallbacks> collidables) {
    final otherCollidables = collidables.toSet()..remove(this);
    return activeCollisions.containsAll(otherCollidables) &&
        otherCollidables.containsAll(activeCollisions);
  }

  @override
  String toString() {
    return name == null
        ? '_TestBlock[${identityHashCode(this)}]'
        : '_TestBlock[$name]';
  }

  Set<Vector2> intersections(TestBlock other) {
    final result = <Vector2>{};
    for (final hitboxA in children.query<HitboxShape>()) {
      for (final hitboxB in other.children.query<HitboxShape>()) {
        result.addAll(hitboxA.intersections(hitboxB));
      }
    }
    return result;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    startCounter++;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    onCollisionCounter++;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    endCounter++;
  }
}
