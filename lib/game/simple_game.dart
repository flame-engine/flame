import 'package:flame/components/component.dart';

import 'base_game.dart';

/// This is a helper implementation of a [BaseGame] designed to allow to easily create a game with a single component.
///
/// This is useful to add sprites, animations and other Flame components "directly" to your non-game Flutter widget tree, when combined with [EmbeddedGameWidget].
class SimpleGame extends BaseGame {
  SimpleGame(Component c) {
    add(c);
  }
}
