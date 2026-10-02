import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('FlameGame.containsEventHandlerAt', () {
    testWithGame(
      'reports a hit everywhere by default',
      FlameGame.new,
      (game) async {
        await game.ensureAdd(_PlainComponent());

        // Games are opaque by default, so the component tree is never checked.
        expect(game.containsEventHandlerAt(Vector2(30, 30)), isTrue);
        expect(game.containsEventHandlerAt(Vector2(400, 300)), isTrue);
      },
    );
  });

  group('DeferHitTestToComponents', () {
    testWithGame(
      'detects any component implementing the marker',
      _DeferringGame.new,
      (game) async {
        await game.ensureAdd(_CustomInputComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isTrue);
        expect(game.containsEventHandlerAt(Vector2(400, 300)), isFalse);
      },
    );

    testWithGame(
      'ignores components that handle no input',
      _DeferringGame.new,
      (game) async {
        await game.ensureAdd(_PlainComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isFalse);
      },
    );

    testWithGame(
      'detects a built-in mixin',
      _DeferringGame.new,
      (game) async {
        await game.ensureAdd(_ScrollComponent());

        expect(game.containsEventHandlerAt(Vector2(30, 30)), isTrue);
      },
    );

    testWidgets(
      'asserts when the game handles pointer events itself',
      (tester) async {
        // This game receives events all over, so there is nothing to defer.
        await tester.pumpWidget(GameWidget(game: _DeferringScrollGame()));
        await tester.pump();

        expect(tester.takeException(), isAssertionError);
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

    testWidgets(
      'translucent hits the game without consulting it',
      (tester) async {
        var buttonTapped = false;
        // With no components, everything is deferred; effectively, transparent.
        final game = _TransparentGame();

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
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          game.renderBox.hitTestSelf(const Offset(400, 300)),
          isTrue,
          reason: 'translucent should not ask the game about the position',
        );

        // Translucent still lets the widgets behind receive the event.
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(buttonTapped, isTrue);
      },
    );
  });
}

mixin _CustomInputCallbacks on Component implements PointerInputCallbacks;

class _TransparentGame() extends FlameGame with DeferHitTestToComponents {
  @override
  Color backgroundColor() => const Color(0x00000000);
}

class _DeferringGame() extends FlameGame with DeferHitTestToComponents;

class _DeferringScrollGame()
    extends FlameGame
    with ScrollCallbacks, DeferHitTestToComponents;

class _Box() extends PositionComponent {
  this : super(position: Vector2.all(10), size: Vector2.all(50));
}

class _PlainComponent() extends _Box;

class _CustomInputComponent() extends _Box with _CustomInputCallbacks;

class _ScrollComponent() extends _Box with ScrollCallbacks;

class _LongPressComponent() extends _Box with LongPressCallbacks {
  int longPressCount = 0;

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    longPressCount++;
  }
}
