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
      final bodyDef = BodyDef()..type = BodyType.dynamic;
      final component = BodyComponent(bodyDef: bodyDef);
      await game.world.ensureAdd(component);
      final body = component.body;

      game.world.removeFromParent();
      await game.ready();
      expect(game.world.physicsWorld.bodies, isNot(contains(body)));
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
      final bodyDef = BodyDef()..type = BodyType.dynamic;
      final component = BodyComponent(bodyDef: bodyDef);
      await game.world.ensureAdd(component);
      final body = component.body;

      game.world.removeFromParent();
      await game.ready();
      expect(game.world.physicsWorld.bodies, contains(body));
    },
  );
}
