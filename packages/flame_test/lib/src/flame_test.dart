import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

extension FlameFinds on CommonFinders {
  Finder byGame<T extends Game>() {
    return find.byWidgetPredicate(
      (widget) => widget is GameWidget<T>,
    );
  }
}

typedef GameCreateFunction<T extends Game> = T Function();
typedef VerifyFunction<T extends Game> = void Function(T);

/// Creates a [Game] specific test case with given [description].
///
/// Use [createGame] to create your game instance.
///
/// Use [verify] closure to make verifications/assertions.
@isTest
void flameTest<T extends Game>(
  String description, {
  required GameCreateFunction<T> createGame,
  required VerifyFunction<T>? verify,
  Vector2? gameSize,
}) {
  test(description, () async {
    final game = createGame();

    final size = gameSize ?? Vector2.all(500);
    game.onGameResize(size);

    await game.onLoad();
    game.update(0);

    if (verify != null) {
      verify(game);
    }
  });
}

typedef GameWidgetCreateFunction<T extends Game> = GameWidget<T> Function(
    T game);
typedef WidgetVerifyFunction<T extends Game> = Future<void> Function(
  T,
  WidgetTester,
);

/// Creates a [Game] specific test case with given [description]
/// which runs inside the flutter inside the Flutter test enviroment.
///
/// Use [createGame] to create your game instance.
///
/// Use [createGameWidget] to create the [GameWidget], if omitted
/// the game instance returned by [createGame] will be wrapped into
/// an empty [GameWidget] instance.
///
/// Use [verify] closure to make verifications/assertions.
@isTest
void flameWidgetTest<T extends Game>(
  String description, {
  required GameCreateFunction<T> createGame,
  GameWidgetCreateFunction<T>? createGameWidget,
  WidgetVerifyFunction<T>? verify,
}) {
  testWidgets(description, (tester) async {
    final game = createGame();

    await tester.runAsync(() async {
      final gameWidget = createGameWidget?.call(game) ?? GameWidget(game: game);

      await tester.pumpWidget(gameWidget);
      await tester.pump();

      if (verify != null) {
        await verify(game, tester);
      }
    });
  });
}
