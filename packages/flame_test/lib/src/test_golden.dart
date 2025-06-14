import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
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
///
/// The [size] parameter controls the size of the "device" on which the game
/// widget is rendered, if omitted it defaults to 2400x1800. This size will be
/// equal to the canvas size of the game.
@isTest
void testGolden(
  String testName,
  PrepareFunction testBody, {
  required String goldenFile,
  Vector2? size,
  Color? backgroundColor,
  FlameGame? game,
  bool skip = false,
}) {
  testWidgets(
    testName,
    (tester) async {
      final gameInstance = game ??
          (backgroundColor != null
              ? GameWithBackgroundColor(backgroundColor)
              : FlameGame());
      const myKey = ValueKey('game-instance');

      await tester.runAsync(() async {
        Widget widget = GameWidget(key: myKey, game: gameInstance);
        if (size != null) {
          widget = Center(
            child: SizedBox(
              width: size.x,
              height: size.y,
              child: RepaintBoundary(
                child: widget,
              ),
            ),
          );
        }
        await tester.pumpWidget(widget);
        await tester.pump();
        await testBody(gameInstance, tester);
        await gameInstance.ready();
        await tester.pump();
      });

      await expectLater(
        find.byKey(myKey),
        matchesGoldenFile(goldenFile),
      );
    },
    skip: skip,
  );
}

typedef PrepareFunction = Future<void> Function(
  FlameGame game,
  WidgetTester tester,
);

class GameWithBackgroundColor extends FlameGame {
  final Color _backgroundColor;

  GameWithBackgroundColor(this._backgroundColor);

  @override
  Color backgroundColor() => _backgroundColor;
}
