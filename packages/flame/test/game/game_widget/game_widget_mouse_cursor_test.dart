import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder byMouseCursor(MouseCursor cursor) {
    return find.byWidgetPredicate(
      (widget) => widget is MouseRegion && widget.cursor == cursor,
    );
  }

  group('GameWidget - MouseCursor', () {
    testWidgets('renders with the initial cursor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameWidget(
            game: FlameGame(),
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
      final game = FlameGame();

      await tester.pumpWidget(
        MaterialApp(
          home: GameWidget(
            game: game,
            mouseCursor: SystemMouseCursors.grab,
          ),
        ),
      );
      await tester.pump();
      expect(game.isAttached, true);

      // Making sure this cursor isn't showing yet
      expect(byMouseCursor(SystemMouseCursors.copy), findsNothing);

      game.mouseCursor = SystemMouseCursors.copy;
      await tester.pump();

      expect(
        byMouseCursor(SystemMouseCursors.copy),
        findsOneWidget,
      );
    });

    testWidgets(
      'can set mouseCursor during onLoad',
      (tester) async {
        final game = GameWithMouseCursorSetDuringOnLoad();
        await tester.pumpWidget(
          GameWidget(game: game),
        );
        await tester.pump();
        expect(
          byMouseCursor(SystemMouseCursors.alias),
          findsOneWidget,
        );
      },
    );
  });
}

class GameWithMouseCursorSetDuringOnLoad extends FlameGame {
  @override
  Future<void>? onLoad() {
    mouseCursor = SystemMouseCursors.alias;
    return null;
  }
}
