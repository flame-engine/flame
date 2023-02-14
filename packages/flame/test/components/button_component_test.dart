import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game_widget/game_widget.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/flame_game_test.dart';

void main() {
  group('ButtonComponent', () {
    testWithGame<GameWithTappables>(
        'correctly registers taps', GameWithTappables.new, (game) async {
      var pressedTimes = 0;
      var releasedTimes = 0;
      var cancelledTimes = 0;
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
          onCancelled: () => cancelledTimes++,
          position: buttonPosition,
          size: componentSize,
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
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 0);
      expect(cancelledTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: buttonPosition.toOffset(),
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
      final buttonPosition = Vector2.all(100);
      late final ButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ButtonComponent(
          button: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          onReleased: () => releasedTimes++,
          onCancelled: () => cancelledTimes++,
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
      expect(cancelledTimes, 0);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      expect(pressedTimes, 1);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 0);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      game.onTapCancel(1);
      expect(pressedTimes, 2);
      expect(releasedTimes, 1);
      expect(cancelledTimes, 1);
    });

    testWidgets(
      '[#1723] can be pressed while the engine is paused',
      (tester) async {
        final game = GameWithTappables();
        game.add(
          ButtonComponent(
            button: CircleComponent(radius: 40),
            position: Vector2(400, 300),
            anchor: Anchor.center,
            onPressed: () {
              game.pauseEngine();
              game.overlays.add('pause-menu');
            },
          ),
        );
        await tester.pumpWidget(
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'pause-menu': (context, _) {
                return SimpleStatelessWidget(
                  build: (context) {
                    return Center(
                      child: OutlinedButton(
                        onPressed: () {
                          game.overlays.remove('pause-menu');
                          game.resumeEngine();
                        },
                        child: const Text('Resume'),
                      ),
                    );
                  },
                );
              },
            },
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.tapAt(const Offset(400, 300));
        await tester.pump(const Duration(seconds: 1));
        expect(game.paused, true);

        await tester.tapAt(const Offset(400, 300));
        await tester.pump(const Duration(seconds: 1));
        expect(game.paused, false);
      },
    );
  });
}

class SimpleStatelessWidget extends StatelessWidget {
  const SimpleStatelessWidget({
    required Widget Function(BuildContext) build,
    super.key,
  }) : _build = build;

  final Widget Function(BuildContext) _build;

  @override
  Widget build(BuildContext context) => _build(context);
}
