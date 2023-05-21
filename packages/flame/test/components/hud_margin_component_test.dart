import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('HudMarginComponent test', () {
    testWithFlameGame(
      'position set from margin should change onGameResize',
      (game) async {
        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );
        await game.ensureAdd(marginComponent);
        // The position should be (770, 560) since the game size is (800, 600)
        // and the component has its anchor in the top left corner (which then
        // is were the margin will be calculated from).
        // (800, 600) - size(20, 20) - position(10, 20) = (770, 560)
        expect(marginComponent.position, closeToVector(Vector2(770, 560)));
        game.onGameResize(Vector2.all(1000));
        game.update(0);
        // After resizing the game, the component should still be 30 pixels from
        // the right edge and 40 pixels from the bottom.
        expect(marginComponent.position, closeToVector(Vector2(970, 960)));
        // After the size of the component is changed the position is also
        // changed.
        marginComponent.size.add(Vector2.all(10));
        expect(marginComponent.position, closeToVector(Vector2(960, 950)));
      },
    );

    testWithFlameGame(
      'position is still correct after a game resize',
      (game) async {
        final world = World();
        final cameraComponent = CameraComponent(world: world);
        game.ensureAddAll([world, cameraComponent]);

        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );

        await cameraComponent.viewport.ensureAdd(marginComponent);
        // The position should be (770, 560) since the game size is (800, 600)
        // and the component has its anchor in the top left corner (which then
        // is were the margin will be calculated from).
        // (800, 600) - size(20, 20) - position(10, 20) = (770, 560)
        expect(marginComponent.position, closeToVector(Vector2(770, 560)));
        game.update(0);
        game.onGameResize(Vector2.all(500));
        game.update(0);
        expect(marginComponent.position, closeToVector(Vector2(770, 560)));
      },
    );

    testWithFlameGame(
      'position is still correct after parent resize and CameraComponent zoom',
      (game) async {
        final world = World();
        final cameraComponent = CameraComponent(world: world);
        game.ensureAddAll([world, cameraComponent]);

        final parent = PositionComponent(
          position: Vector2(10, 20),
          size: Vector2(50, 40),
        );
        await world.ensureAdd(parent);

        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );

        await parent.ensureAdd(marginComponent);
        expect(marginComponent.position, closeToVector(Vector2(20, 00)));
        parent.size = Vector2.all(500);
        expect(marginComponent.position, closeToVector(Vector2(470, 460)));
        cameraComponent.viewfinder.zoom = 2.0;
        game.update(0);
        expect(marginComponent.position, closeToVector(Vector2(470, 460)));
      },
    );
  });
}
