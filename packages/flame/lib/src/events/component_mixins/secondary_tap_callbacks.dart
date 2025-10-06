import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive secondary
/// tap events (i.e. right mouse clicks).
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "tapped" if the point where the tap has occurred is inside the component.
///
/// Note that FlameGame _is_ a [Component] and does implement
/// [containsLocalPoint]; so this can be used at the game level.
mixin SecondaryTapCallbacks on Component {
  void onSecondaryTapDown(SecondaryTapDownEvent event) {}
  void onSecondaryTapUp(SecondaryTapUpEvent event) {}
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const SecondaryTapDispatcherKey()) == null) {
      final dispatcher = SecondaryTapDispatcher();
      game.registerKey(const SecondaryTapDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
