import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/sprite_group_component.dart';
import 'package:flame/src/events/flame_game_mixins/multi_tap_dispatcher.dart';
import 'package:flame/src/sprite_sheet.dart';
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

  group('CustomSpriteButtonComponent', () {
    testWithFlameGame('correctly registers taps', (game) async {
      final initialGameSize = Vector2.all(100);
      final componentSize = Vector2.all(10);
      final buttonPosition = Vector2.all(100);
      late final CustomSpriteButtonComponent button;
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
        button = CustomSpriteButtonComponent(
          customButton: buttonSheet.getSpriteById(0),
          customButtonDown: buttonSheet.getSpriteById(1),
          customOnPressed: () => component.current = _ButtonState.up,
          customPosition: buttonPosition,
          customSize: componentSize,
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
      late final CustomSpriteButtonComponent button;
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
        button = CustomSpriteButtonComponent(
          customButton: buttonSheet.getSpriteById(0),
          customButtonDown: buttonSheet.getSpriteById(1),
          customOnPressed: () => component.current = _ButtonState.up,
          customPosition: buttonPosition,
          customSize: componentSize,
        ),
      );

      final previousPosition = button.positionOfAnchor(Anchor.center)
          .toOffset();
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
          CustomSpriteButtonComponent(
            customButton: buttonSheet.getSpriteById(0),
            customButtonDown: buttonSheet.getSpriteById(1),
            customOnPressed: () {
              game.pauseEngine();
              game.overlays.add('pause-menu');
            },
            customPosition: Vector2(400, 300),
            customSize: Vector2.all(10),
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

  testWithFlameGame('can change button sprites', (game) async {
    final buttonSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 1,
      rows: 2,
    );

    final button = CustomSpriteButtonComponent(
      customButton: buttonSheet.getSpriteById(0),
      customButtonDown: buttonSheet.getSpriteById(1),
    );

    await game.ensureAdd(button);

    expect(
      button.sprites,
      {
        ButtonState.up: buttonSheet.getSpriteById(0),
        ButtonState.down: buttonSheet.getSpriteById(1),
      },
    );

    button.button = buttonSheet.getSpriteById(1);
    button.buttonDown = buttonSheet.getSpriteById(0);

    expect(
      button.sprites,
      {
        ButtonState.up: buttonSheet.getSpriteById(1),
        ButtonState.down: buttonSheet.getSpriteById(0),
      },
    );
  });
}

/// test class [CustomSpriteButtonComponent] extending
/// the [SpriteButtonComponent] class,
/// To test [SpriteButtonComponent] without using Constructor
/// but setting properties in [onLoad]
///
class CustomSpriteButtonComponent extends SpriteButtonComponent {
  final Sprite customButton;
  final Sprite customButtonDown;
  final void Function()? customOnPressed;
  final Vector2? customPosition;
  final Vector2? customSize;

  CustomSpriteButtonComponent({
    required this.customButton,
    required this.customButtonDown,
    this.customOnPressed,
    this.customPosition,
    this.customSize,});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    position = customPosition ?? Vector2(0.0, 0.0);
    button = customButton;
    buttonDown = customButtonDown;
    onPressed = customOnPressed;
  }
}

class _SimpleStatelessWidget extends StatelessWidget {
  const _SimpleStatelessWidget({
    required Widget Function(BuildContext) build,
  }) : _build = build;

  final Widget Function(BuildContext) _build;

  @override
  Widget build(BuildContext context) => _build(context);
}
