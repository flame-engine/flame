import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnchorToEffect', () {
    testWithFlameGame('simple anchor movement', (game) async {
      final object = PositionComponent()
        ..position = Vector2(3, 4)
        ..anchor = Anchor.bottomRight;
      game.add(object);
      await game.ready();

      object.add(
        AnchorToEffect(Anchor.center, EffectController(duration: 1)),
      );
      game.update(0.5);
      expect(object.position, Vector2(3, 4));
      expect(object.anchor.x, closeTo(0.75, 1e-15));
      expect(object.anchor.y, closeTo(0.75, 1e-15));

      game.update(0.5);
      expect(object.anchor.x, closeTo(0.5, 1e-15));
      expect(object.anchor.y, closeTo(0.5, 1e-15));
    });

    testWithFlameGame('viewfinder move anchor', (game) async {
      final world = World()..addToParent(game);
      final camera = CameraComponent(world: world)..addToParent(game);
      await game.ready();

      expect(camera.viewfinder.anchor, Anchor.center);
      camera.viewfinder.add(
        AnchorToEffect(const Anchor(0.2, 0.6), EffectController(duration: 1)),
      );
      for (var t = 0.0; t <= 1.0; t += 0.1) {
        expect(camera.viewfinder.anchor.x, closeTo(0.5 - 0.3 * t, 1e-15));
        expect(camera.viewfinder.anchor.y, closeTo(0.5 + 0.1 * t, 1e-15));
        game.update(0.1);
      }
    });
  });
}
