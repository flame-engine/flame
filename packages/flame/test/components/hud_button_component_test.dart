import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/src/events/flame_game_mixins/multi_tap_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HudButtonComponent', () {
    testWithFlameGame('correctly registers taps', (game) async {
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
      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(1, TapDownDetails());
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition:
              initialGameSize.toOffset() +
              margin.bottomRight -
              const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition:
              initialGameSize.toOffset() +
              margin.bottomRight -
              const Offset(1, 1),
        ),
      );
      tapDispatcher.handleTapCancel(1);
      expect(pressedTimes, 2);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 1);
    });

    testWithFlameGame('correctly registers taps onGameResize', (game) async {
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
      final previousPosition = button
          .positionOfAnchor(Anchor.center)
          .toOffset();
      game.onGameResize(initialGameSize * 2);
      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: previousPosition),
      );
      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: previousPosition),
      );
      expect(pressedTimes, 0);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition:
              game.size.toOffset() + margin.bottomRight - const Offset(1, 1),
        ),
      );
      tapDispatcher.handleTapCancel(1);
      expect(pressedTimes, 2);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 1);
    });

    testWithFlameGame('can set button and buttonDown in onLoad', (game) async {
      expect(
        () => game.ensureAdd(_CustomHudButtonComponent()),
        returnsNormally,
      );
    });
  });
}

class _CustomHudButtonComponent extends HudButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    button = RectangleComponent(size: Vector2.all(10));
    buttonDown = CircleComponent(radius: 10);
  }
}
