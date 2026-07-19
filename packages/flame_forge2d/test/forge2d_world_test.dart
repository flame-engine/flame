import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestForge2DWorld extends Forge2DWorld {
  _TestForge2DWorld() : super(gravity: Vector2(0, 0));
}

void main() {
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
}
