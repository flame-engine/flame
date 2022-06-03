import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Test that a game renders correctly.
///
/// The way golden tests work is as follows: you set up a scene in [testBody],
/// then the test framework renders your game widget into an image, and compares
/// that image against stored [goldenFile]. The test passes if two images are
/// identical, or fails if the images differ even in a single pixel.
///
/// The term _golden file_ refers to the true rendering of a given game scene,
/// captured at the creation of the test. In order to create a golden file, you
/// first specify its desired name in the [goldenFile] parameter, and then run
/// the tests using the command
/// ```
/// flutter test --update-goldens
/// ```
///
/// The [testBody] is given a `game` parameter (which is by default a new
/// [FlameGame] instance, but you can also supply your own [game] object), and
/// is expected to set up a scene for rendering. Usually this involves adding
/// necessary game components, and possibly advancing the game clock. As a
/// convenience, we will run `await game.ready()` before rendering, to ensure
/// that all components that might be pending are properly mounted.
@isTest
void testGolden(
  String testName,
  PrepareGameFunction testBody, {
  required String goldenFile,
  FlameGame? game,
  bool skip = false,
}) {
  testWidgets(
    testName,
    (tester) async {
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
    },
    skip: skip,
  );
}

typedef PrepareGameFunction = Future<void> Function(FlameGame game);
