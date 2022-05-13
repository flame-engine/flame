import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Test that a game renders correctly.
///
///
@isTest
void testGolden(
  String testName,
  PrepareGameFunction testBody, {
  required String goldenFile,
  FlameGame? game,
}) {
  testWidgets(testName, (tester) async {
    final gameInstance = game ?? FlameGame();

    await tester.runAsync(() async {
      await tester.pumpWidget(GameWidget(game: gameInstance));
      await tester.pump();
      await testBody(gameInstance);
      await gameInstance.ready();
      await tester.pump();
    });

    await expectLater(
      find.byWidgetPredicate((widget) => widget is GameWidget),
      matchesGoldenFile(goldenFile),
    );
  });
}

typedef PrepareGameFunction = Future<void> Function(FlameGame game);
