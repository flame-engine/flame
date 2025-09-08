import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestForge2DWorld extends Forge2DWorld {
  _TestForge2DWorld() : super(gravity: Vector2(0, 0));
}

void main() {
  testWithFlameGame(
    'Bodies are set to awake after remounting the world',
    (game) async {
      final world = _TestForge2DWorld();
      game.add(world);
      await game.ready();
      final bodyDef = BodyDef()..type = BodyType.dynamic;
      final body = world.createBody(bodyDef);
      await game.ready();
      expect(body.isAwake, isTrue);
      game.update(100);
      expect(body.isAwake, isFalse);

      world.removeFromParent();
      game.add(world);
      await game.ready();
      expect(body.isAwake, isTrue);
    },
  );
}
