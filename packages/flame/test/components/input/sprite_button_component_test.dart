import 'package:flame/input.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame/src/components/sprite_group_component.dart';
import 'package:flame/src/spritesheet.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../game/flame_game_test.dart';

enum _ButtonState {
  up,
  down,
}

Future<void> main() async {
  // Generate an image
  final image = await generateImage();

  group('SpriteButtonComponent', () {
    testWithGame<GameWithTappables>(
        'correctly registers taps', GameWithTappables.new, (game) async {
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

      game.onTapDown(1, createTapDownEvent(game));
      expect(component.current, _ButtonState.down);

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: buttonPosition.toOffset(),
        ),
      );
      expect(component.current, _ButtonState.down);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(component.current, _ButtonState.up);
    });

    testWithGame<GameWithTappables>(
        'correctly registers taps onGameResize', GameWithTappables.new,
        (game) async {
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

      game.onTapDown(
        1,
        createTapDownEvent(
          game,
          globalPosition: previousPosition,
        ),
      );
      expect(component.current, _ButtonState.down);

      game.onTapUp(
        1,
        createTapUpEvent(
          game,
          globalPosition: button.positionOfAnchor(Anchor.center).toOffset(),
        ),
      );
      expect(component.current, _ButtonState.up);
    });
  });
}
