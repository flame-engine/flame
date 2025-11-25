import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/multi_tap_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToggleButtonComponent', () {
    testWithFlameGame('correctly registers taps', (game) async {
      var pressedTimes = 0;
      final initialGameSize = Vector2.all(200);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ToggleButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ToggleButtonComponent(
          defaultSkin: RectangleComponent(size: componentSize),
          defaultSelectedSkin: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          position: buttonPosition,
          size: componentSize,
        ),
      );

      expect(pressedTimes, 0);
      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(1, TapDownDetails());
      expect(pressedTimes, 0);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(pressedTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: buttonPosition.toOffset()),
      );
      expect(pressedTimes, 1);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: buttonPosition.toOffset()),
      );
      expect(pressedTimes, 1);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: buttonPosition.toOffset()),
      );
      tapDispatcher.handleTapCancel(1);
      expect(pressedTimes, 2);
    });

    testWithFlameGame('correctly registers taps onGameResize', (game) async {
      var pressedTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ToggleButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ToggleButtonComponent(
          defaultSkin: RectangleComponent(size: componentSize),
          defaultSelectedSkin: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          position: buttonPosition,
          size: componentSize,
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
      expect(pressedTimes, 1);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: previousPosition),
      );
      expect(pressedTimes, 1);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: previousPosition),
      );
      tapDispatcher.handleTapCancel(1);
      expect(pressedTimes, 2);
    });

    testWithFlameGame('correctly work isDisabled', (game) async {
      var pressedTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ToggleButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ToggleButtonComponent(
          defaultSkin: RectangleComponent(size: componentSize),
          defaultSelectedSkin: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          position: buttonPosition,
          size: componentSize,
        ),
      );
      button.isDisabled = true;
      final previousPosition = button
          .positionOfAnchor(Anchor.center)
          .toOffset();
      game.onGameResize(initialGameSize * 2);
      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: previousPosition),
      );
      expect(pressedTimes, 0);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: previousPosition),
      );
      expect(pressedTimes, 0);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: previousPosition),
      );
      tapDispatcher.handleTapCancel(1);
      expect(pressedTimes, 0);
    });

    testWithFlameGame('toggle works correctly', (game) async {
      var pressedTimes = 0;
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final ToggleButtonComponent button;
      game.onGameResize(initialGameSize);
      await game.ensureAdd(
        button = ToggleButtonComponent(
          defaultSkin: RectangleComponent(size: componentSize),
          defaultSelectedSkin: RectangleComponent(size: componentSize),
          onPressed: () => pressedTimes++,
          position: buttonPosition,
          size: componentSize,
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
      expect(button.isSelected, false);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: previousPosition),
      );
      expect(button.isSelected, true);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(globalPosition: previousPosition),
      );
      expect(button.isSelected, true);

      tapDispatcher.handleTapUp(
        1,
        createTapUpDetails(globalPosition: previousPosition),
      );
      expect(button.isSelected, false);
    });

    testWidgets(
      '[#1723] can be pressed while the engine is paused',
      (tester) async {
        final game = FlameGame();
        game.add(
          ToggleButtonComponent(
            defaultSkin: CircleComponent(radius: 40),
            downSkin: CircleComponent(radius: 40),
            defaultSelectedSkin: CircleComponent(radius: 40),
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
                return _SimpleStatelessWidget(
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

class _SimpleStatelessWidget extends StatelessWidget {
  const _SimpleStatelessWidget({
    required Widget Function(BuildContext) build,
  }) : _build = build;

  final Widget Function(BuildContext) _build;

  @override
  Widget build(BuildContext context) => _build(context);
}
