import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentViewportMargin', () {
    testWithFlameGame(
      'margin should stay same after GameResize',
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

        final expectedNewPosition = game.size.toOffset() +
            margin.bottomRight -
            componentSize.toOffset();

        expect(initialMargin, equals(marginAfterGameResize));

        expect(actualNewPosition, equals(expectedNewPosition));
      },
    );
  });
}

class _ComponentWithViewportMargin extends PositionComponent
    with HasGameRef, ComponentViewportMargin {}
