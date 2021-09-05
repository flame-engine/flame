import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestGame extends Game {
  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {}
}

Finder byMouseCursor(MouseCursor cursor) {
  return find.byWidgetPredicate(
    (widget) => widget is MouseRegion && widget.cursor == cursor,
  );
}

void main() {
  group('GameWidget - MouseCursor', () {
    testWidgets('renders with the initial cursor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameWidget(
            game: TestGame(),
            mouseCursor: SystemMouseCursors.grab,
          ),
        ),
      );

      expect(
        byMouseCursor(SystemMouseCursors.grab),
        findsOneWidget,
      );
    });

    testWidgets('can change the cursor', (tester) async {
      final game = TestGame();

      await tester.pumpWidget(
        MaterialApp(
          home: GameWidget(
            game: game,
            mouseCursor: SystemMouseCursors.grab,
          ),
        ),
      );

      // Making sure this cursor isn't showing yet
      expect(byMouseCursor(SystemMouseCursors.copy), findsNothing);

      game.mouseCursor.value = SystemMouseCursors.copy;
      await tester.pump();

      expect(
        byMouseCursor(SystemMouseCursors.copy),
        findsOneWidget,
      );
    });
  });
}
