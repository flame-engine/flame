import 'package:flame/game.dart';

/// Utility function for writing tests that require a [FlameGame] instance.
///
/// This function creates a [FlameGame] object, properly initializes it, then
/// passes on to the user-provided test [testBody], and in the end disposes of
/// the game object.
///
/// Example of usage:
/// ```dart
/// test(
///   'MyComponent can be added to a game',
///   withFlameGame((game) async {
///     final component = MyComponent()..addToParent(game);
///     await game.ready();
///     expect(component.isMounted, true);
///   }),
/// );
/// ```
///
/// The `game` instance supplied by this function to your test [testBody] is a
/// standard [FlameGame]. If you want to have any other game instance, use the
/// [withUserGame] function.
AsyncVoidFunction withFlameGame(AsyncGameFunction<FlameGame> testBody) {
  return withUserGame<FlameGame>(() => FlameGame(), testBody);
}

/// Utility function for writing tests that require a custom game instance.
///
/// This function [create]s the game instance, initializes it, then passes it
/// to the user-provided test [testBody], and in the end disposes of the game
/// object.
///
/// Example of usage:
/// ```dart
/// test(
///   'MyComponent can be added to MyGame',
///   withUserGame(
///     () => MyGame(mySecret: 3781),
///     (MyGame game) async {
///       final component = MyComponent()..addToParent(game);
///       await game.ready();
///       expect(component.isMounted, true);
///     },
///   ),
/// );
/// ```
AsyncVoidFunction withUserGame<T extends FlameGame>(
  CreateFunction<T> create,
  AsyncGameFunction<T> testBody,
) {
  Future<void> testFn() async {
    final game = create();
    game.onGameResize(Vector2(800, 600));
    await game.onLoad();
    game.onMount();
    game.update(0);

    await testBody(game);

    game.onRemove();
  }

  return testFn;
}

typedef CreateFunction<T> = T Function();
typedef AsyncVoidFunction = Future<void> Function();
typedef AsyncGameFunction<T extends Game> = Future<void> Function(T game);
