import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Vector2 size = Vector2(1.0, 1.0);

class _KeyboardEventsGame extends FlameGame with KeyboardEvents {
  final List<String> keysPressed = [];

  _KeyboardEventsGame();

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
  _HasKeyboardHandlerComponentsGame();

  late _KeyboardHandlerComponent keyboardHandler;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    keyboardHandler = _KeyboardHandlerComponent();
    add(keyboardHandler);
  }
}

class _GamePage extends StatelessWidget {
  final Widget child;

  const _GamePage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: child,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: ElevatedButton(
                child: const Text('Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  testWidgets('Adds focus', (tester) async {
    final focusNode = FocusNode();

    final game = _KeyboardEventsGame();

    await tester.pumpWidget(
      _GamePage(
        child: GameWidget(
          game: game,
          focusNode: focusNode,
        ),
      ),
    );

    expect(focusNode.hasFocus, true);
  });

  testWidgets('KeyboardEvents receives keys', (tester) async {
    final game = _KeyboardEventsGame();

    await tester.pumpWidget(
      _GamePage(
        child: GameWidget(
          game: game,
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);

    expect(game.keysPressed, ['a', 'b', 'c']);
  });

  testWidgets('HasKeyboardHandlerComponents receives keys', (tester) async {
    final game = _HasKeyboardHandlerComponentsGame();

    await tester.pumpWidget(
      _GamePage(
        child: GameWidget(
          game: game,
        ),
      ),
    );

    game.onGameResize(size);
    game.update(0.1);

    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyI);

    expect(game.keyboardHandler.keysPressed, ['z', 'f', 'i']);
  });
}
