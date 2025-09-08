import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestForge2DWorld extends Forge2DWorld {
  _TestForge2DWorld() : super(gravity: Vector2(0, 0));
}

void main() {
  testWithFlameGame(
    'Bodies are destroyed after world is removed when destroyBodiesOnRemove is '
    'true',
    (game) async {
      final world = _TestForge2DWorld();
      game.add(world);
      await game.ready();
      final bodyDef = BodyDef()..type = BodyType.dynamic;
      final component = BodyComponent(bodyDef: bodyDef);
      world.add(component);
      await game.ready();
      final body = component.body;

      world.removeFromParent();
      await game.ready();
      expect(world.physicsWorld.bodies, isNot(contains(body)));
    },
  );

  testWithFlameGame(
    'Bodies are not destroyed after world is removed when '
    'destroyBodiesOnRemove is false',
    (game) async {
      final world = _TestForge2DWorld()..destroyBodiesOnRemove = false;
      game.add(world);
      await game.ready();
      final bodyDef = BodyDef()..type = BodyType.dynamic;
      final component = BodyComponent(bodyDef: bodyDef);
      world.add(component);
      await game.ready();
      final body = component.body;

      world.removeFromParent();
      await game.ready();
      expect(world.physicsWorld.bodies, contains(body));
    },
  );
}
