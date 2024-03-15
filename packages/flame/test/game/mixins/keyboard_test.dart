import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _ValidGame extends FlameGame with KeyboardEvents {}

class _InvalidGame extends FlameGame
    with HasKeyboardHandlerComponents, KeyboardEvents {}

void main() {
  group('Keyboard events', () {
    test(
      'game with KeyboardEvents can handle key events',
      () {
        final validGame = _ValidGame();
        const event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        );

        // Should just work with the default implementation
        expect(
          validGame.onKeyEvent(event, {}),
          KeyEventResult.handled,
        );
      },
    );

    test(
      'cannot mix KeyboardEvent and HasKeyboardHandlerComponents together',
      () {
        final invalidGame = _InvalidGame();
        const event = KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowUp,
          logicalKey: LogicalKeyboardKey.arrowUp,
          timeStamp: Duration.zero,
        );

        // Should throw an assertion error
        expect(
          () => invalidGame.onKeyEvent(event, {}),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });
}
