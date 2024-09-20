import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Utility function for writing tests that require a [FlameGame] instance.
///
/// This function creates a [FlameGame] object, properly initializes it, then
/// passes on to the user-provided [testBody], and in the end disposes of the
/// game object.
///
/// Example of usage:
/// ```dart
/// testWithFlameGame(
///   'MyComponent can be added to a game',
///   (game) async {
///     final component = MyComponent()..addToParent(game);
///     await game.ready();
///     expect(component.isMounted, true);
///   },
/// );
/// ```
///
/// The `game` instance supplied by this function to your [testBody] is a
/// standard [FlameGame]. If you want to have any other game instance, use the
/// [testWithGame] function.
@isTest
Future<void> testWithFlameGame(
  String testName,
  AsyncGameFunction<FlameGame> testBody, {
  Timeout? timeout,
  dynamic tags,
  dynamic skip,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  return testWithGame<FlameGame>(
    testName,
    FlameGame.new,
    testBody,
    timeout: timeout,
    tags: tags,
    skip: skip,
    onPlatform: onPlatform,
    retry: retry,
  );
}

/// Utility function for writing tests that require a custom game instance.
///
/// This function [create]s the game instance, initializes it, then passes it
/// to the user-provided [testBody], and in the end disposes of the game object.
///
/// Example of usage:
/// ```dart
/// testWithGame<MyGame>(
///   'MyComponent can be added to MyGame',
///   () => MyGame(mySecret: 3781),
///   (MyGame game) async {
///     final component = MyComponent()..addToParent(game);
///     await game.ready();
///     expect(component.isMounted, true);
///   },
/// );
/// ```
@isTest
Future<void> testWithGame<T extends FlameGame>(
  String testName,
  CreateFunction<T> create,
  AsyncGameFunction<T> testBody, {
  Timeout? timeout,
  dynamic tags,
  dynamic skip,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) async {
  test(
    testName,
    () async {
      final game = await initializeGame<T>(create);

      try {
        await testBody(game);
      } finally {
        game.onRemove();
      }
    },
    timeout: timeout,
    tags: tags,
    skip: skip,
    onPlatform: onPlatform,
    retry: retry,
  );
}

Future<T> initializeGame<T extends FlameGame>(CreateFunction<T> create) async {
  final game = create();
  game.onGameResize(Vector2(800, 600));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

Future<FlameGame> initializeFlameGame() => initializeGame(FlameGame.new);

typedef CreateFunction<T> = T Function();
typedef AsyncVoidFunction = Future<void> Function();
typedef AsyncGameFunction<T extends Game> = Future<void> Function(T game);
