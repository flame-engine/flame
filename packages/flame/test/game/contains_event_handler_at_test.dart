import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameGame.containsEventHandlerAt', () {
    testWithGame(
      'detects any component implementing the marker',
      FlameGame.new,
      (game) async {
        await game.ensureAdd(_CustomInputComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isTrue);
        expect(game.containsEventHandlerAt(Vector2(400, 300)), isFalse);
      },
    );

    testWithGame(
      'ignores components that handle no input',
      FlameGame.new,
      (game) async {
        await game.ensureAdd(_PlainComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isFalse);
      },
    );

    testWithGame(
      'detects a built-in mixin',
      FlameGame.new,
      (game) async {
        await game.ensureAdd(_ScrollComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isTrue);
      },
    );

    testWithGame(
      'detects a game that handles input itself',
      _ScrollGame.new,
      (game) async {
        // FlameGame is itself a Component, so componentsAtPoint yields the
        // game and any in-bounds point counts as a hit.
        expect(game.containsEventHandlerAt(Vector2(400, 300)), isTrue);
        expect(game.containsEventHandlerAt(Vector2(900, 700)), isFalse);
      },
    );
  });

  group('GameWidget hit test', () {
    testWidgets(
      'long presses reach a LongPressCallbacks component under deferToChild',
      (tester) async {
        var buttonTapped = false;
        final component = _LongPressComponent()
          ..size = Vector2(800, 600)
          ..position = Vector2.zero();
        final game = _TransparentGame()..add(component);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () => buttonTapped = true,
                      child: const Text('Tap me'),
                    ),
                  ),
                  Positioned.fill(
                    child: GameWidget(
                      game: game,
                      behavior: HitTestBehavior.deferToChild,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        await tester.longPressAt(const Offset(400, 300));
        await tester.pump(const Duration(milliseconds: 100));

        expect(component.longPressCount, equals(1));
        expect(buttonTapped, isFalse);
      },
    );
  });
}

mixin _CustomInputCallbacks on Component implements PointerInputCallbacks {}

class _TransparentGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}

class _ScrollGame extends FlameGame with ScrollCallbacks {}

class _Box extends PositionComponent {
  _Box() : super(position: Vector2.all(10), size: Vector2.all(50));
}

class _PlainComponent extends _Box {}

class _CustomInputComponent extends _Box with _CustomInputCallbacks {}

class _ScrollComponent extends _Box with ScrollCallbacks {}

class _LongPressComponent extends _Box with LongPressCallbacks {
  int longPressCount = 0;

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    longPressCount++;
  }
}
