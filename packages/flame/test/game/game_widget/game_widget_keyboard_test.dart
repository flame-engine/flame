import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _KeyboardEventsGame() extends FlameGame with KeyboardEvents {
  final List<String> keysPressed = [];

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    this.keysPressed.add(event.character ?? 'none');

    return KeyEventResult.handled;
  }
}

class _KeyboardHandlerComponent() extends Component with KeyboardHandler {
  final List<String> keysPressed = [];

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    this.keysPressed.add(event.character ?? 'none');
    return false;
  }
}

class _HasKeyboardHandlerComponentsGame()
    extends FlameGame
    with HasKeyboardHandlerComponents {
  late _KeyboardHandlerComponent keyboardHandler;

  @override
  Future<void> onLoad() async {
    keyboardHandler = _KeyboardHandlerComponent();
    add(keyboardHandler);
  }
}

class const _GamePage({required final Widget child}) extends StatelessWidget {
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

void main() {
  final size = Vector2(1.0, 1.0);

  group('GameWidget', () {
    testWidgets('adds focus', (tester) async {
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

    testWidgets('game with KeyboardEvents receives key events', (tester) async {
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

    testWidgets(
      'a game that replaces another one takes the focus back',
      (tester) async {
        // Something else, like a button next to the game, takes the focus.
        final otherNode = FocusNode();
        Widget page(FlameGame game) => _GamePage(
          child: Column(
            children: [
              Focus(focusNode: otherNode, child: const SizedBox.square()),
              Expanded(child: GameWidget(game: game)),
            ],
          ),
        );

        await tester.pumpWidget(page(_KeyboardEventsGame()));
        otherNode.requestFocus();
        await tester.pump();

        final newGame = _KeyboardEventsGame();
        await tester.pumpWidget(page(newGame));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);

        expect(otherNode.hasFocus, isFalse);
        expect(newGame.keysPressed, ['a']);
      },
    );

    testWidgets(
      'a game that replaces another one does not take the focus without '
      'autofocus',
      (tester) async {
        final otherNode = FocusNode();
        Widget page(FlameGame game) => _GamePage(
          child: Column(
            children: [
              Focus(focusNode: otherNode, child: const SizedBox.square()),
              Expanded(child: GameWidget(game: game, autofocus: false)),
            ],
          ),
        );

        await tester.pumpWidget(page(_KeyboardEventsGame()));
        otherNode.requestFocus();
        await tester.pump();

        await tester.pumpWidget(page(_KeyboardEventsGame()));

        expect(otherNode.hasFocus, isTrue);
      },
    );

    testWidgets(
      'game with HasKeyboardHandlerComponents receives key events',
      (tester) async {
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
      },
    );
  });

  group('GameWidget.managed', () {
    testWidgets('adds focus', (tester) async {
      final focusNode = FocusNode();

      final game = _KeyboardEventsGame();

      await tester.pumpWidget(
        _GamePage(
          child: GameWidget.managed(
            gameFactory: () => game,
            focusNode: focusNode,
          ),
        ),
      );

      expect(focusNode.hasFocus, true);
    });

    testWidgets('game with KeyboardEvents receives key events', (tester) async {
      final game = _KeyboardEventsGame();

      await tester.pumpWidget(
        _GamePage(
          child: GameWidget.managed(
            gameFactory: () => game,
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);

      expect(game.keysPressed, ['a', 'b', 'c']);
    });

    testWidgets(
      'game with HasKeyboardHandlerComponents receives key events',
      (tester) async {
        final game = _HasKeyboardHandlerComponentsGame();

        await tester.pumpWidget(
          _GamePage(
            child: GameWidget.managed(
              gameFactory: () => game,
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
      },
    );
  });
}
