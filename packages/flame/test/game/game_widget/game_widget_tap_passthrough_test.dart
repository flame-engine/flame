import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TransparentGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
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
  });
}
