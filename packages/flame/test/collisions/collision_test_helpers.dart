import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_test/flame_test.dart';
import 'package:meta/meta.dart';

class HasCollidablesGame() extends FlameGame with HasCollisionDetection;

class HasQuadTreeCollidablesGame()
    extends FlameGame
    with HasQuadTreeCollisionDetection;

class CollisionDetectionWorld() extends World with HasCollisionDetection;

@isTest
void testCollisionDetectionGame(
  String testName,
  Future<void> Function(HasCollidablesGame) testBody,
) {
  return testWithGame(testName, HasCollidablesGame.new, testBody);
}

@isTest
void testQuadTreeCollisionDetectionGame(
  String testName,
  Future<void> Function(HasCollisionDetection) testBody,
) {
  return testWithGame(
    testName,
    () {
      final game = HasQuadTreeCollidablesGame();
      game.initializeCollisionDetection(
        mapDimensions: const Rect.fromLTWH(0, 0, 1000, 1000),
      );
      return game;
    },
    testBody,
  );
}

Future<void> runCollisionTestRegistry(
  Map<String, Future<void> Function(HasCollisionDetection)> testRegistry,
) async {
  for (final entry in testRegistry.entries) {
    final name = entry.key;
    final testFunction = entry.value;
    testCollisionDetectionGame('[Sweep] $name', testFunction);
    testQuadTreeCollisionDetectionGame('[QuadTree] $name', testFunction);
  }
}

class TestHitbox([var String? name]) extends RectangleHitbox {
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;
  this {
    onCollisionCallback = (_, _) {
      onCollisionCounter++;
    };
    onCollisionStartCallback = (_, _) {
      startCounter++;
    };
    onCollisionEndCallback = (_) {
      endCounter++;
    };
  }

  @override
  String toString() {
    return name == null
        ? '_TestHitbox[${identityHashCode(this)}]'
        : '_TestHitbox[$name]';
  }
}

class CompositeTestHitbox({super.size, super.children})
    extends CompositeHitbox {
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  this {
    onCollisionCallback = (_, _) {
      onCollisionCounter++;
    };
    onCollisionStartCallback = (_, _) {
      startCounter++;
    };
    onCollisionEndCallback = (_) {
      endCounter++;
    };
  }
}

class TestBlock(
  Vector2 position,
  Vector2 size, {
  CollisionType type = CollisionType.active,
  bool addTestHitbox = true,
  super.children,
  var String? name,
  final bool Function(PositionComponent other)? _onComponentTypeCheck,
}) extends PositionComponent with CollisionCallbacks {
  final hitbox = TestHitbox();
  int startCounter = 0;
  int onCollisionCounter = 0;
  int endCounter = 0;

  this
    : super(
        position: position,
        size: size,
      ) {
    children.register<ShapeHitbox>();
    if (addTestHitbox) {
      add(hitbox..collisionType = type);
    }
  }

  @override
  bool collidingWith(PositionComponent other) {
    return activeCollisions.contains(other);
  }

  bool collidedWithExactly(List<PositionComponent> collidables) {
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

  List<Vector2> intersections(TestBlock other) {
    final result = <Vector2>[];
    for (final hitboxA in children.query<ShapeHitbox>()) {
      for (final hitboxB in other.children.query<ShapeHitbox>()) {
        result.addAll(hitboxA.intersections(hitboxB));
      }
    }
    return result;
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    startCounter++;
  }

  @override
  void onCollision(List<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    onCollisionCounter++;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    endCounter++;
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    return (_onComponentTypeCheck?.call(other) ?? true) &&
        super.onComponentTypeCheck(other);
  }
}

class Water({super.position, super.size, super.children})
    extends PositionComponent;

class Brick({super.position, super.size, super.children})
    extends PositionComponent;
