import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/flame_game_test.dart';

void main() {
  group('HudButtonComponent', () {
    testWithGame<GameWithTappables>(
        'correctly registers taps', GameWithTappables.new, (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      var cancelledTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      const margin = EdgeInsets.only(bottom: 10, right: 10);
      late final HudButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = HudButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          onCancelled: () => cancelledTimes++,
          size: componentSize,
          margin: margin,
        ),
      );

      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapDown(1, createTapDownEvent(game));
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: initialGameSize.toOffset() +
              margin.bottomRight -
              const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: initialGameSize.toOffset() +
              margin.bottomRight -
              const Offset(1, 1),
        ),
      );
      game.onTapCancel(1);
      expect(pressedTimes, 2);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 1);
    });

    testWithGame<GameWithTappables>(
        'correctly registers taps onGameResize', GameWithTappables.new,
        (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      var cancelledTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      const margin = EdgeInsets.only(bottom: 10, right: 10);
      late final HudButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = HudButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          onCancelled: () => cancelledTimes++,
          size: componentSize,
          margin: margin,
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
      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      game.onTapCancel(1);
      expect(pressedTimes, 2);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 1);
    });
  });
}
