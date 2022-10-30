import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ValidGame extends FlameGame with KeyboardEvents {}

class _InvalidGame extends FlameGame
    with HasKeyboardHandlerComponents, KeyboardEvents {}

class _MockRawKeyEventData extends Mock implements RawKeyEventData {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

void main() {
  group('Keyboard events', () {
    test(
      'game with KeyboardEvents can handle key events',
      () {
        final validGame = _ValidGame();
        final event = RawKeyDownEvent(data: _MockRawKeyEventData());

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
        final event = RawKeyDownEvent(data: _MockRawKeyEventData());

        // Should throw an assertion error
        expect(
          () => invalidGame.onKeyEvent(event, {}),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });
}
