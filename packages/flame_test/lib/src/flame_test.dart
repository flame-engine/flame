import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test show test;
import 'package:flutter_test/flutter_test.dart' hide test;
import 'package:meta/meta.dart';

extension FlameFinds on CommonFinders {
  Finder byGame<T extends Game>() {
    return find.byWidgetPredicate(
      (widget) => widget is GameWidget<T>,
    );
  }
}

@visibleForTesting
extension FlameGameExtension on Component {
  /// Makes sure that the [component] is added to the tree if you wait for the
  /// returned future to resolve.
  Future<void> ensureAdd(Component component) async {
    await add(component);
    await (component.findGame()! as FlameGame).ready();
  }

  /// Makes sure that the [components] are added to the tree if you wait for the
  /// returned future to resolve.
  Future<void> ensureAddAll(Iterable<Component> components) async {
    await addAll(components);
    await (components.first.findGame()! as FlameGame).ready();
  }
}

typedef GameCreateFunction<T extends Game> = T Function();
typedef VerifyFunction<T extends Game> = dynamic Function(T);

typedef GameWidgetCreateFunction<T extends Game> = GameWidget<T> Function(
  T game,
);
typedef WidgetVerifyFunction<T extends Game> = Future<void> Function(
  T,
  WidgetTester,
);
typedef WidgetSetupFunction<T extends Game> = Future<void> Function(
  T,
  WidgetTester,
);
typedef PumpWidgetFunction<T extends Game> = Future<void> Function(
  GameWidget<T>,
  WidgetTester tester,
);

/// Customize this class with your specific Game type [T] and a custom
/// provider `() -> T`, plus some additional configurations including a game
/// widget builder [createGameWidget], a custom [pumpWidget] function and a
/// custom [gameSize].
class GameTester<T extends Game> {
  /// Use [createGame] to create your game instance.
  final GameCreateFunction<T> createGame;

  /// Use [createGameWidget] to create the [GameWidget]. If omitted,
  /// the game instance returned by [createGame] will be wrapped into
  /// an empty [GameWidget] instance.
  final GameWidgetCreateFunction<T>? createGameWidget;

  /// Use [pumpWidget] to define your own function to pump widgets into
  /// the Flutter test environment. When omitted, [testGameWidget] simply
  /// will pass the created game widget instance to the test.
  final PumpWidgetFunction<T>? pumpWidget;

  /// Override the game size to be provided during `onGameResize`.
  /// By default it will be a 500x500 square.
  final Vector2? gameSize;

  /// If true, the game will be brought into the "fully ready" state (meaning
  /// all its pending lifecycle events will be resolved) before the start of
  /// the test.
  bool makeReady = true;

  GameTester(
    this.createGame, {
    this.gameSize,
    this.createGameWidget,
    this.pumpWidget,
  });

  Future<T> initializeGame() async {
    final game = createGame();

    final size = gameSize ?? Vector2.all(500);
    game.onGameResize(size);

    await game.onLoad();
    game.update(0);
    if (game is FlameGame && makeReady) {
      await game.ready();
    }
    return game;
  }

  /// Creates a [Game] specific test case with given [description].
  ///
  /// Use [verify] closure to make verifications/assertions.
  @isTest
  void test(
    String description,
    VerifyFunction<T> verify, {
    String? skip,
    String? testOn,
    Timeout? timeout,
    dynamic tags,
    Map<String, dynamic>? onPlatform,
    int? retry,
  }) {
    flutter_test.test(
      description,
      () async {
        final game = await initializeGame();
        await verify(game);
      },
      skip: skip,
      testOn: testOn,
      timeout: timeout,
      tags: tags,
      onPlatform: onPlatform,
      retry: retry,
    );
  }

  /// Creates a [Game] specific test case with given [description]
  /// which runs inside the Flutter test environment.
  ///
  /// Use [verify] closure to make verifications/assertions.
  @isTest
  @Deprecated('Use testGameWidget instead, will be removed in v1.3.0')
  void widgetTest(
    String description,
    WidgetVerifyFunction<T>? verify, {
    bool? skip,
    Timeout? timeout,
    bool? semanticsEnabled,
    dynamic tags,
  }) {
    testGameWidget(
      description,
      verify: verify,
      skip: skip,
      timeout: timeout,
      semanticsEnabled: semanticsEnabled,
      tags: tags,
    );
  }

  /// Creates a [Game] specific test case with given [description]
  /// which runs inside the Flutter test environment.
  ///
  /// Use [setUp] closure to prepare your game instance (e.g. add components to
  /// it)
  /// Use [verify] closure to make verifications/assertions.
  @isTest
  void testGameWidget(
    String description, {
    WidgetSetupFunction<T>? setUp,
    WidgetVerifyFunction<T>? verify,
    bool? skip,
    Timeout? timeout,
    bool? semanticsEnabled,
    dynamic tags,
  }) {
    testWidgets(
      description,
      (tester) async {
        final game = createGame();

        await tester.runAsync(() async {
          final gameWidget =
              createGameWidget?.call(game) ?? GameWidget(game: game);

          final _pump = pumpWidget ??
              (GameWidget<T> _gameWidget, WidgetTester _tester) =>
                  _tester.pumpWidget(_gameWidget);

          await _pump(gameWidget, tester);
          await tester.pump();

          if (setUp != null) {
            await setUp.call(game, tester);
            await tester.pump();
          }
        });

        if (verify != null) {
          await verify(game, tester);
        }
      },
      skip: skip,
      timeout: timeout,
      semanticsEnabled: semanticsEnabled ?? true,
      tags: tags,
    );
  }

  GameTester<T> configure({
    GameCreateFunction<T>? createGame,
    Vector2? gameSize,
    GameWidgetCreateFunction<T>? createGameWidget,
    PumpWidgetFunction<T>? pumpWidget,
  }) {
    return GameTester<T>(
      createGame ?? this.createGame,
      gameSize: gameSize ?? this.gameSize,
      createGameWidget: createGameWidget ?? this.createGameWidget,
      pumpWidget: pumpWidget ?? this.pumpWidget,
    );
  }
}

/// Customize this class with your specific FlameGame type [T] and a custom
/// provider `() -> T`, plus some additional configurations including a game
/// widget builder [createGameWidget], a custom [pumpWidget] function and a
/// custom [gameSize].
class FlameTester<T extends FlameGame> extends GameTester<T> {
  FlameTester(
    super.createGame, {
    super.gameSize,
    super.createGameWidget,
    super.pumpWidget,
  });
}

/// Default instance of Flame Tester to be used when you don't care about
/// changing any configuration.
final flameGame = FlameTester<FlameGame>(FlameGame.new);
