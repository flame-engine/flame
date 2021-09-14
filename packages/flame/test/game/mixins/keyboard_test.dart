import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ValidGame extends FlameGame with KeyboardEvents {}

class InvalidGame extends FlameGame
    with HasKeyboardHandlerComponents, KeyboardEvents {}

class MockRawKeyEventData extends Mock implements RawKeyEventData {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

void main() {
  group('Keyboard events', () {
    test(
      'cannot mix KeyboardEvent and HasKeyboardHandlerComponents together',
      () {
        final validGame = ValidGame();
        final invalidGame = InvalidGame();

        final event = RawKeyDownEvent(data: MockRawKeyEventData());

        // Should just work with the default implementation
        expect(
          validGame.onKeyEvent(event, {}),
          KeyEventResult.handled,
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
