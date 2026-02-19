import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TransparentGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}

class _TrackingGame extends FlameGame {
  int componentsAtPointCallCount = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) {
    componentsAtPointCallCount++;
    return super.componentsAtPoint(point, nestedPoints);
  }
}

class _TappableComponent extends PositionComponent with TapCallbacks {
  int tapDownCount = 0;
  int tapUpCount = 0;

  @override
  void onTapDown(TapDownEvent event) {
    tapDownCount++;
  }

  @override
  void onTapUp(TapUpEvent event) {
    tapUpCount++;
  }
}

void main() {
  group('GameWidget - tap passthrough', () {
    testWidgets(
      'taps reach a Flutter button behind a transparent GameWidget',
      (tester) async {
        var buttonTapped = false;
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

        await tester.tap(find.text('Tap me'));
        await tester.pump();

        expect(buttonTapped, isTrue);
      },
    );

    testWidgets(
      'taps on a TapCallbacks component are intercepted',
      (tester) async {
        var buttonTapped = false;
        final component = _TappableComponent()
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

        await tester.tapAt(const Offset(400, 300));
        await tester.pump(const Duration(milliseconds: 100));

        expect(component.tapDownCount, equals(1));
        expect(component.tapUpCount, equals(1));
        expect(buttonTapped, isFalse);
      },
    );

    testWidgets(
      'taps on empty game space pass through even when TapCallbacks '
      'components exist elsewhere',
      (tester) async {
        var buttonTapped = false;
        // Small component in the top-left corner, far from the button
        final component = _TappableComponent()
          ..size = Vector2(50, 50)
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

        // Tap the button area (center of screen) which is NOT over
        // the small component in the corner
        await tester.tap(find.text('Tap me'));
        await tester.pump();

        expect(component.tapDownCount, equals(0));
        expect(buttonTapped, isTrue);
      },
    );
    testWidgets(
      'translucent behavior delivers events to both game component and '
      'widget behind',
      (tester) async {
        var pointerDownReceived = false;
        final component = _TappableComponent()
          ..size = Vector2(800, 600)
          ..position = Vector2.zero();
        final game = _TransparentGame()..add(component);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Listener(
                      onPointerDown: (_) => pointerDownReceived = true,
                      child: const ColoredBox(color: Color(0xFF0000FF)),
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
        expect(component.isMounted, isTrue);

        await tester.tapAt(const Offset(400, 300));
        await tester.pump(const Duration(milliseconds: 100));

        expect(component.tapDownCount, equals(1));
        expect(pointerDownReceived, isTrue);
      },
    );

    testWidgets(
      'opaque behavior blocks taps from reaching widgets behind',
      (tester) async {
        var buttonTapped = false;
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
                    child: GameWidget(game: game),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.tap(find.text('Tap me'), warnIfMissed: false);
        await tester.pump();

        expect(buttonTapped, isFalse);
      },
    );

    testWidgets(
      'componentsAtPoint is not called redundantly during hit testing',
      (tester) async {
        final game = _TrackingGame();
        final component = _TappableComponent()
          ..size = Vector2(800, 600)
          ..position = Vector2.zero();
        game.add(component);

        await tester.pumpWidget(
          MaterialApp(
            home: GameWidget(game: game),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(component.isMounted, isTrue);

        game.componentsAtPointCallCount = 0;

        await tester.tapAt(const Offset(100, 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Hit test should reuse its traversal for event delivery,
        // so we expect only 2 calls (tap down + tap up), not 3.
        expect(game.componentsAtPointCallCount, equals(2));
      },
    );
  });
}
