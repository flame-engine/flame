import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestForge2DWorld extends Forge2DWorld {
  _TestForge2DWorld() : super(gravity: Vector2(0, 0));
}

void main() {
  // Forge2D has to be initialized before a world can be created, which
  // Forge2DGame does automatically but a bare Forge2DWorld does not.
  setUpAll(initializeForge2D);

  group('gravity before the physics world is created', () {
    test('the gravity argument takes precedence over the definition', () {
      final world = Forge2DWorld(
        gravity: Vector2(1, 2),
        definition: WorldDef(gravity: Vector2(0, -10)),
      );
      expect(world.gravity, Vector2(1, 2));
      expect(world.physicsWorld.gravity, Vector2(1, 2));
      world.physicsWorld.destroy();
    });

    test('the definition gravity is used when no gravity is given', () {
      final world = Forge2DWorld(
        definition: WorldDef(gravity: Vector2(0, -10)),
      );
      expect(world.physicsWorld.gravity, Vector2(0, -10));
      world.physicsWorld.destroy();
    });

    test('a gravity set before creation is picked up by the created world', () {
      final world = Forge2DWorld()..gravity = Vector2(3, 4);
      expect(world.gravity, Vector2(3, 4));
      expect(world.physicsWorld.gravity, Vector2(3, 4));
      world.physicsWorld.destroy();
    });

    test('setting gravity to null falls back to the default gravity', () {
      final world = Forge2DWorld(gravity: Vector2(3, 4))..gravity = null;
      expect(world.gravity, Forge2DWorld.defaultGravity);
      expect(world.physicsWorld.gravity, Forge2DWorld.defaultGravity);
      world.physicsWorld.destroy();
    });
  });

  testWithGame(
    'Bodies are destroyed after world is removed when destroyBodiesOnRemove is '
    'true',
    () => Forge2DGame(world: _TestForge2DWorld()),
    (game) async {
      await game.ready();
      final bodyDef = BodyDef(type: BodyType.dynamic);
      final component = BodyComponent(bodyDef: bodyDef);
      await game.world.ensureAdd(component);
      final body = component.body;

      game.world.removeFromParent();
      await game.ready();
      expect(game.world.bodies, isNot(contains(body)));
      expect(body.isValid, isFalse);
    },
  );

  testWithGame(
    'Bodies are not destroyed after world is removed when '
    'destroyBodiesOnRemove is false',
    () => Forge2DGame(
      world: _TestForge2DWorld()..destroyBodiesOnRemove = false,
    ),
    (game) async {
      await game.ready();
      final bodyDef = BodyDef(type: BodyType.dynamic);
      final component = BodyComponent(bodyDef: bodyDef);
      await game.world.ensureAdd(component);
      final body = component.body;

      game.world.removeFromParent();
      await game.ready();
      expect(game.world.bodies, contains(body));
      expect(body.isValid, isTrue);
    },
  );

  testWithGame(
    'subStepCount defaults to 4 and can be changed',
    Forge2DGame.new,
    (game) async {
      expect(game.world.subStepCount, 4);
      game.world.subStepCount = 8;
      expect(game.world.subStepCount, 8);
    },
  );

  testWithGame(
    'gravity setter wakes up bodies',
    Forge2DGame.new,
    (game) async {
      final body = game.world.createBody(BodyDef(type: BodyType.dynamic));
      body.createShape(Circle(radius: 1));
      body.isAwake = false;
      expect(body.isAwake, isFalse);

      game.world.gravity = Vector2(0, 5);

      expect(game.world.gravity, Vector2(0, 5));
      expect(body.isAwake, isTrue);
    },
  );

  testWithGame(
    'bodies destroyed outside of destroyBody are dropped',
    Forge2DGame.new,
    (game) async {
      final kept = game.world.createBody(BodyDef(type: BodyType.dynamic));
      kept.createShape(Circle(radius: 1));
      final destroyed = game.world.createBody(BodyDef(type: BodyType.dynamic));
      destroyed.createShape(Circle(radius: 1));
      expect(game.world.bodies, hasLength(2));

      // Destroying the body directly bypasses Forge2DWorld.destroyBody, so
      // the world is left holding a stale handle.
      destroyed.destroy();

      expect(game.world.bodies, {kept});
      // Waking the bodies must not touch the destroyed one, since Box2D
      // reuses its slot and the stale handle would write to whichever body
      // took its place.
      expect(() => game.world.gravity = Vector2(0, 5), returnsNormally);
      expect(kept.isAwake, isTrue);
    },
  );

  testWithGame(
    'castRayClosest returns the closest hit',
    Forge2DGame.new,
    (game) async {
      final near = game.world.createBody(BodyDef(position: Vector2(10, 0)));
      near.createShape(Circle(radius: 1));
      final far = game.world.createBody(BodyDef(position: Vector2(15, 0)));
      far.createShape(Circle(radius: 1));

      final hit = game.world.castRayClosest(Vector2.zero(), Vector2(20, 0));

      expect(hit, isNotNull);
      expect(hit!.shape.body, near);
      expect(hit.point.x, closeTo(9, 1e-4));
    },
  );

  testWithGame(
    'castRay reports every hit through the callback',
    Forge2DGame.new,
    (game) async {
      game.world
          .createBody(BodyDef(position: Vector2(10, 0)))
          .createShape(
            Circle(radius: 1),
          );
      game.world
          .createBody(BodyDef(position: Vector2(15, 0)))
          .createShape(
            Circle(radius: 1),
          );

      final hits = <RayHit>[];
      game.world.castRay(Vector2.zero(), Vector2(20, 0), (hit) {
        hits.add(hit);
        return 1;
      });

      expect(hits, hasLength(2));
    },
  );

  testWithGame(
    'castRayAll returns the hits sorted from nearest to farthest',
    Forge2DGame.new,
    (game) async {
      final far = game.world.createBody(BodyDef(position: Vector2(15, 0)));
      far.createShape(Circle(radius: 1));
      final near = game.world.createBody(BodyDef(position: Vector2(10, 0)));
      near.createShape(Circle(radius: 1));

      final hits = game.world.castRayAll(Vector2.zero(), Vector2(20, 0));

      expect(hits, hasLength(2));
      expect(hits.first.shape.body, near);
      expect(hits.last.shape.body, far);
    },
  );

  testWithGame(
    'overlapAabb returns the shapes overlapping the aabb',
    Forge2DGame.new,
    (game) async {
      final inside = game.world.createBody(BodyDef(position: Vector2(5, 5)));
      final insideShape = inside.createShape(Circle(radius: 1));
      final outside = game.world.createBody(BodyDef(position: Vector2(50, 50)));
      outside.createShape(Circle(radius: 1));

      final overlapping = game.world.overlapAabb(
        Aabb(Vector2.zero(), Vector2.all(10)),
      );

      expect(overlapping, [insideShape]);
      expect(
        game.world.overlapAabb(Aabb(Vector2(20, 20), Vector2(30, 30))),
        isEmpty,
      );
    },
  );

  testWithGame(
    'preSolveCallback can veto a contact',
    Forge2DGame.new,
    (game) async {
      final platform = game.world.createBody(BodyDef(position: Vector2(0, 5)));
      platform.createShape(
        Polygon.box(10, 1),
        ShapeDef(enablePreSolveEvents: true),
      );
      final ball = game.world.createBody(BodyDef(type: BodyType.dynamic));
      ball.createShape(
        Circle(radius: 1),
        ShapeDef(enablePreSolveEvents: true),
      );

      var preSolveCalls = 0;
      game.world.preSolveCallback = (shapeA, shapeB, normal) {
        preSolveCalls++;
        return false;
      };

      for (var i = 0; i < 120; i++) {
        game.update(1 / 60);
      }

      // The vetoed contact never stopped the falling ball, so it has dropped
      // through the platform.
      expect(preSolveCalls, greaterThan(0));
      expect(ball.position.y, greaterThan(6));
    },
  );

  testWithGame(
    'customFilterCallback can disable a collision',
    Forge2DGame.new,
    (game) async {
      final platform = game.world.createBody(BodyDef(position: Vector2(0, 5)));
      platform.createShape(Polygon.box(10, 1));
      final ball = game.world.createBody(BodyDef(type: BodyType.dynamic));
      ball.createShape(Circle(radius: 1));

      var filterCalls = 0;
      game.world.customFilterCallback = (shapeA, shapeB) {
        filterCalls++;
        return false;
      };

      for (var i = 0; i < 120; i++) {
        game.update(1 / 60);
      }

      // The filtered pair never collided, so the ball has fallen through the
      // platform.
      expect(filterCalls, greaterThan(0));
      expect(ball.position.y, greaterThan(6));
    },
  );
}
