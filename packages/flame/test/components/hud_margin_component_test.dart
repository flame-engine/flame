import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() async {
  group('HudMarginComponent test', () {
    flameGame.test(
      'position set from margin should change onGameResize',
      (game) async {
        final marginComponent = HudMarginComponent(
          margin: const EdgeInsets.only(right: 10, bottom: 20),
          size: Vector2.all(20),
        );
        await game.add(marginComponent);
        game.update(0);
        // The position should be (470, 460) since the game size is (500, 500)
        // and the component has its anchor in the top left corner (which then
        // is were the margin will be calculated from).
        // (500, 500) - size(20, 20) - position(10, 20) = (470, 460)
        expectVector2(marginComponent.position, Vector2(470.0, 460.0));
        game.onGameResize(Vector2.all(1000));
        game.update(0);
        // After resizing the game, the component should still be 30 pixels from
        // the right edge and 40 pixels from the bottom.
        expectVector2(marginComponent.position, Vector2(970.0, 960.0));
        // After the size of the component is changed the position is also
        // changed.
        marginComponent.size.add(Vector2.all(10));
        expectVector2(marginComponent.position, Vector2(960.0, 950.0));
      },
    );
  });
}
