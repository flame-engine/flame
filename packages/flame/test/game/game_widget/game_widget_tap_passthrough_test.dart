import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TransparentGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
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
                    child: GameWidget(game: game),
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
                    child: GameWidget(game: game),
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
                    child: GameWidget(game: game),
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
  });
}
