import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _TestForge2dGame extends Forge2DGame {
  _TestForge2dGame() : super(zoom: 4.0, gravity: Vector2(0, -10.0));
}

void main() {
  group(
    'Test corresponding position on screen and in the Forge2D world',
    () {
      testWithGame(
        'Center positioned camera should be zero in world',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          game.update(0);
          game.onGameResize(size);
          expect(
            game.screenToWorld(size / 2),
            Vector2.zero(),
          );
        },
      );

      testWithGame(
        'Top left position should be converted correctly to world',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          game.onGameResize(size);
          expect(
            game.screenToWorld(Vector2.zero()),
            -(size / 2) / game.camera.viewfinder.zoom,
          );
        },
      );

      testWithGame(
        'Non-zero position should be converted correctly to world',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          final screenPosition = Vector2(10, 20);
          game.onGameResize(size);
          expect(
            game.screenToWorld(screenPosition),
            (-size / 2 + screenPosition) / game.camera.viewfinder.zoom,
          );
        },
      );

      testWithGame(
        'Converts a vector in the world space to the screen space',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          game.onGameResize(size);
          expect(
            game.worldToScreen(Vector2.zero()),
            size / 2,
          );
        },
      );

      testWithGame(
        'Converts a non-zero vector in the world space to the screen space',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          final worldPosition = Vector2.all(10);
          game.onGameResize(size);
          expect(
            game.worldToScreen(worldPosition),
            (size / 2) + worldPosition * game.camera.viewfinder.zoom,
          );
        },
      );

      testWithGame(
        'Converts worldToScreen correctly with moved viewfinder',
        _TestForge2dGame.new,
        (game) async {
          final size = Vector2.all(100);
          final worldPosition = Vector2(10, 30);
          final viewfinderPosition = Vector2(20, 10);
          game.onGameResize(size);
          game.camera.viewfinder.position = viewfinderPosition;
          expect(
            game.worldToScreen(worldPosition),
            (size / 2) +
                (worldPosition - viewfinderPosition) *
                    game.camera.viewfinder.zoom,
          );
        },
      );

      test("Game does not override World's gravity with null", () {
        final game = Forge2DGame(world: Forge2DWorld(gravity: Vector2(10, 0)));
        expect(game.world.gravity.x, 10);
        expect(game.world.gravity.y, 0);
      });
    },
  );
}
