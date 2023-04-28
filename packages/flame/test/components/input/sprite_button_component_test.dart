import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/sprite_group_component.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:flame/src/spritesheet.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _ButtonState {
  up,
  down,
}

Future<void> main() async {
  // Generate an image
  final image = await generateImage();

  group('SpriteButtonComponent', () {
    testWithFlameGame('correctly registers taps', (game) async {
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final SpriteButtonComponent button;
      game.onGameResize(initialGameSize);

      final buttonSheet = SpriteSheet.fromColumnsAndRows(
        image: image,
        columns: 1,
        rows: 2,
      );

      final component = SpriteGroupComponent<_ButtonState>(
        sprites: {
          _ButtonState.up: buttonSheet.getSpriteById(0),
          _ButtonState.down: buttonSheet.getSpriteById(1),
        },
      );
      component.current = _ButtonState.down;

      await game.ensureAdd(
        button = SpriteButtonComponent(
          button: buttonSheet.getSpriteById(0),
          buttonDown: buttonSheet.getSpriteById(1),
          onPressed: () => component.current = _ButtonState.up,
          position: buttonPosition,
          size: componentSize,
        ),
      );

      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(1, TapDownDetails());
      expect(component.current, _ButtonState.down);

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(component.current, _ButtonState.down);

      tapDispatcher.handleTapUp(
        1,
        TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(component.current, _ButtonState.up);
    });

    testWithFlameGame('correctly registers taps onGameResize', (game) async {
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final SpriteButtonComponent button;
      game.onGameResize(initialGameSize);

      final buttonSheet = SpriteSheet.fromColumnsAndRows(
        image: image,
        columns: 1,
        rows: 2,
      );

      final component = SpriteGroupComponent<_ButtonState>(
        sprites: {
          _ButtonState.up: buttonSheet.getSpriteById(0),
          _ButtonState.down: buttonSheet.getSpriteById(1),
        },
      );
      component.current = _ButtonState.down;

      await game.ensureAdd(
        button = SpriteButtonComponent(
          button: buttonSheet.getSpriteById(0),
          buttonDown: buttonSheet.getSpriteById(1),
          onPressed: () => component.current = _ButtonState.up,
          position: buttonPosition,
          size: componentSize,
        ),
      );

      final previousPosition =
          button.positionOfAnchor(Anchor.center).toOffset();
      game.onGameResize(initialGameSize * 2);
      final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

      tapDispatcher.handleTapDown(
        1,
        TapDownDetails(
          globalPosition: previousPosition,
        ),
      );
      expect(component.current, _ButtonState.down);

      tapDispatcher.handleTapUp(
        1,
        TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(component.current, _ButtonState.up);
    });

    testWidgets(
      'Button can be pressed while the engine is paused',
      (tester) async {
        final game = FlameGame();

        final buttonSheet = SpriteSheet.fromColumnsAndRows(
          image: image,
          columns: 1,
          rows: 2,
        );

        final component = SpriteGroupComponent<_ButtonState>(
          sprites: {
            _ButtonState.up: buttonSheet.getSpriteById(0),
            _ButtonState.down: buttonSheet.getSpriteById(1),
          },
        );
        component.current = _ButtonState.down;

        game.add(
          SpriteButtonComponent(
            button: buttonSheet.getSpriteById(0),
            buttonDown: buttonSheet.getSpriteById(1),
            onPressed: () {
              game.pauseEngine();
              game.overlays.add('pause-menu');
            },
            position: Vector2(400, 300),
            size: Vector2.all(10),
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
