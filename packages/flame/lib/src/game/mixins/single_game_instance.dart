import 'package:flame/src/components/component.dart';
import 'package:flame/src/game/mixins/game.dart';

/// Mixin that declares a [Game] class as a singleton.
///
/// In many applications there is a single [Game] instance within the entire
/// app. For example, most regular game apps fall within this category. If your
/// application is structured like that, you can use this mixin to declare your
/// game class as a "singleton game".
///
/// The effect of using this mixin is that it allows component lifecycle events
/// to be resolved faster in certain situations. For example, [Component]'s
/// `onLoad` will be able to run even if its parent is currently detached.
///
/// Using this mixin in applications where there are multiple [Game] instances
/// attached to multiple GameWidgets, is invalid.
mixin SingleGameInstance on Game {
  @override
  void onMount() {
    Component.staticGameInstance = this;
    super.onMount();
  }

  @override
  void onRemove() {
    super.onRemove();
    Component.staticGameInstance = null;
  }
}
