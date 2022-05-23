import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class _KeyCallStub {
  bool onCall(Set<LogicalKeyboardKey> keysPressed);
}

class KeyCallStub extends Mock implements _KeyCallStub {}

class MockRawKeyUpEvent extends Mock implements RawKeyUpEvent {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

RawKeyUpEvent _mockKeyUp(LogicalKeyboardKey key) {
  final event = MockRawKeyUpEvent();
  when(() => event.logicalKey).thenReturn(key);
  return event;
}

void main() {
  group('KeyboardListenerComponent', () {
    test('calls registered handlers', () {
      final stub = KeyCallStub();
      when(() => stub.onCall(any())).thenReturn(true);

      final input = KeyboardListenerComponent(
        keyUp: {
          LogicalKeyboardKey.arrowUp: stub.onCall,
        },
      );

      input.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.arrowUp), {});
      verify(() => stub.onCall({})).called(1);
    });

    test(
      'returns false the handler return value',
      () {
        final stub = KeyCallStub();
        when(() => stub.onCall(any())).thenReturn(false);

        final input = KeyboardListenerComponent(
          keyUp: {
            LogicalKeyboardKey.arrowUp: stub.onCall,
          },
        );

        expect(
          input.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.arrowUp), {}),
          isFalse,
        );
      },
    );

    test(
      'returns true (allowing event to bubble) when no handler is registered',
      () {
        final stub = KeyCallStub();
        when(() => stub.onCall(any())).thenReturn(true);

        final input = KeyboardListenerComponent();

        expect(
          input.onKeyEvent(_mockKeyUp(LogicalKeyboardKey.arrowUp), {}),
          isTrue,
        );
      },
    );
  });
}
