import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/flame_game_test.dart';

void main() {
  group('ButtonComponent', () {
    testWithGame<GameWithTappables>(
        'correctly registers taps', GameWithTappables.new, (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          position: buttonPosition,
          size: componentSize,
        ),
      );

      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapDown(1, createTapDownEvent(game));
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
    });

    testWithGame<GameWithTappables>(
        'correctly registers taps onGameResize', GameWithTappables.new,
        (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          position: buttonPosition,
          size: componentSize,
        ),
      );
      final previousPosition =
          button.positionOfAnchor(Anchor.center).toOffset();
      game.onGameResize(initialGameSize * 2);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
    });
  });
}
