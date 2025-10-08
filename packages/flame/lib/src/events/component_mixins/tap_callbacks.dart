import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive tap events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only be considered
/// "tapped" if the point where the tap has occurred is inside the component.
///
/// Note that FlameGame _is_ a [Component] and does implement
/// [containsLocalPoint]; so this can be used at the game level.
mixin TapCallbacks on Component {
  void onTapDown(TapDownEvent event) {}
  void onLongTapDown(TapDownEvent event) {}
  void onTapUp(TapUpEvent event) {}
  void onTapCancel(TapCancelEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const MultiTapDispatcherKey()) == null) {
      final dispatcher = MultiTapDispatcher();
      game.registerKey(const MultiTapDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
