import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentViewportMargin', () {
    testWithGame(
      'margin should stay same after GameResize',
      _TestGame.new,
      (game) async {
        final initialGameSize = Vector2.all(100);
        final componentSize = Vector2.all(10);
        const margin = EdgeInsets.only(bottom: 10, right: 10);

        final component = _ComponentWithViewportMargin()
          ..size = componentSize
          ..margin = margin;

        game.onGameResize(initialGameSize);

        await game.ensureAdd(component);

        final initialMargin = component.margin;

        game.onGameResize(initialGameSize * 2);

        final marginAfterGameResize = component.margin;

        final actualNewPosition = component.position.toOffset();

        final expectedNewPosition =
            game.size.toOffset() +
            margin.bottomRight -
            componentSize.toOffset();

        expect(initialMargin, equals(marginAfterGameResize));

        expect(actualNewPosition, equals(expectedNewPosition));
      },
    );
  });
}

class _TestGame extends FlameGame<World> {}

class _ComponentWithViewportMargin extends PositionComponent
    with HasGameReference<_TestGame>, ComponentViewportMargin<_TestGame> {}
