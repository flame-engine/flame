import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('HudMarginComponent test', () {
    flameGame.test(
      'position set from margin should change onGameResize',
      (game) async {
        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );
        await game.ensureAdd(marginComponent);
        // The position should be (470, 460) since the game size is (500, 500)
        // and the component has its anchor in the top left corner (which then
        // is were the margin will be calculated from).
        // (500, 500) - size(20, 20) - position(10, 20) = (470, 460)
        expect(marginComponent.position, closeToVector(470, 460));
        game.onGameResize(Vector2.all(1000));
        game.update(0);
        // After resizing the game, the component should still be 30 pixels from
        // the right edge and 40 pixels from the bottom.
        expect(marginComponent.position, closeToVector(970, 960));
        // After the size of the component is changed the position is also
        // changed.
        marginComponent.size.add(Vector2.all(10));
        expect(marginComponent.position, closeToVector(960, 950));
      },
    );

    flameGame.test(
      'position is still correct after zooming and a game resize',
      (game) async {
        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );
        await game.ensureAdd(marginComponent);
        // The position should be (470, 460) since the game size is (500, 500)
        // and the component has its anchor in the top left corner (which then
        // is were the margin will be calculated from).
        // (500, 500) - size(20, 20) - position(10, 20) = (470, 460)
        expect(marginComponent.position, closeToVector(470, 460));
        game.update(0);
        game.camera.zoom = 2.0;
        game.onGameResize(Vector2.all(500));
        game.update(0);
        expect(marginComponent.position, closeToVector(470, 460));
      },
    );
  });
}
