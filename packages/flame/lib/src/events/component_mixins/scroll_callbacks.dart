import 'package:flame/components.dart';
import 'package:flame/src/events/flame_game_mixins/scroll_dispatcher.dart';
import 'package:flame/src/events/messages/scroll_event.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// pointer scroll (mouse wheel) events.
mixin ScrollCallbacks on Component {
  void onScroll(ScrollEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    onMountHandler(this);
  }

  static void onMountHandler(ScrollCallbacks instance) {
    final game = instance.findRootGame()!;
    const key = ScrollDispatcherKey();
    if (game.findByKey(key) == null) {
      final dispatcher = ScrollDispatcher();
      game.registerKey(key, dispatcher);
      game.add(dispatcher);
    }
  }
}
