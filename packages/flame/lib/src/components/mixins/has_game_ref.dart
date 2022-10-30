import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/experimental/has_game_reference.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game.dart';
import 'package:flame/src/game/mixins/single_game_instance.dart';
import 'package:meta/meta.dart';

/// [HasGameRef] mixin provides property [game] (or [gameRef]), which is the
/// cached accessor for the top-level game instance.
///
/// The type [T] on the mixin is the type of your game class. This type will be
/// the type of the [game] reference, and the mixin will check at runtime that
/// the actual type matches the expectation.
///
/// [HasGameReference] is a newer version of this mixin, and will replace it in
/// Flame v2.0.
mixin HasGameRef<T extends FlameGame> on Component {
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

  /// Equivalent to the [game] property.
  T get gameRef => game;

  /// Directly assigns (and override if one is already set) a [gameRef] to the
  /// component.
  ///
  /// This is meant to be used only for testing purposes.
  @visibleForTesting
  @Deprecated('Use .game setter instead. Will be removed in 1.5.0')
  void mockGameRef(T gameRef) => _game = gameRef;

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
