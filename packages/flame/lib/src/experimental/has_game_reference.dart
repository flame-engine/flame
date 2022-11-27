import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/has_game_ref.dart';
import 'package:flame/src/game/game.dart';
import 'package:flame/src/game/mixins/single_game_instance.dart';

/// [HasGameReference] mixin provides property [game], which is the cached
/// accessor for the top-level game instance.
///
/// The type [T] on the mixin is the type of your game class. This type will be
/// the type of the [game] reference, and the mixin will check at runtime that
/// the actual type matches the expectation.
///
/// This class is equivalent to [HasGameRef] in all respects except that its
/// generic parameter [T] can be any [Game], not just a "FlameGame".
mixin HasGameReference<T extends Game> on Component {
  T? _game;

  /// Reference to the top-level Game instance that owns this component.
  ///
  /// This property is accessible in the component's `onLoad` and later. It may
  /// be accessible earlier too, but only if your game uses the
  /// [SingleGameInstance] mixin.
  T get game => _game ??= _findGameAndCheck();

  /// Allows you to set the game instance explicitly. This may be useful in
  /// tests, or if you're planning to move the component to another game
  /// instance.
  set game(T? value) => _game = value;

  @override
  Game? findGame() => _game ?? super.findGame();

  T _findGameAndCheck() {
    final game = findGame();
    assert(
      game != null,
      'Could not find Game instance: the component is detached from the '
      'component tree',
    );
    assert(
      game! is T,
      'Found game of type ${game.runtimeType}, while type $T was expected',
    );
    return game! as T;
  }
}
