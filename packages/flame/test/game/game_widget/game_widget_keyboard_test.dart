import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _KeyboardEventsGame extends FlameGame with KeyboardEvents {
  final List<String> keysPressed = [];

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    this.keysPressed.add(event.character ?? 'none');
    return KeyEventResult.handled;
  }
}

class _KeyboardHandlerComponent extends Component with KeyboardHandler {
  final List<String> keysPressed = [];

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    this.keysPressed.add(event.character ?? 'none');
    return false;
  }
}

class _HasKeyboardHandlerComponentsGame extends FlameGame
    with HasKeyboardHandlerComponents {
  _HasKeyboardHandlerComponentsGame({super.children});
}

void main() {
  testWidgets('adds focus', (tester) async {
    final focusNode = FocusNode();
    await tester.pumpWidget(
      GameWidget(
        game: _KeyboardEventsGame(),
        focusNode: focusNode,
      ),
    );
    await tester.pump();

    expect(focusNode.hasFocus, true);
  });

  testWidgets('game with KeyboardEvents receives keys', (tester) async {
    final game = _KeyboardEventsGame();
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);

    expect(game.keysPressed, ['a', 'b', 'c']);
  });

  testWidgets(
    'game with HasKeyboardHandlerComponents receives keys',
    (tester) async {
      final keyboardHandler = _KeyboardHandlerComponent();
      final game = _HasKeyboardHandlerComponentsGame(
        children: [keyboardHandler],
      );

      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyI);

      expect(keyboardHandler.keysPressed, ['z', 'f', 'i']);
    },
  );
}
