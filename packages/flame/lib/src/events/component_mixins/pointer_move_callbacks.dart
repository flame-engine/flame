import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// pointer movement events.
mixin PointerMoveCallbacks on Component {
  void onPointerMove(PointerMoveEvent event) {}

  void onPointerMoveStop(PointerMoveEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    onMountHandler(this);
  }

  static void onMountHandler(PointerMoveCallbacks instance) {
    final game = instance.findRootGame()!;
    const key = MouseMoveDispatcherKey();
    if (game.findByKey(key) == null) {
      final dispatcher = PointerMoveDispatcher();
      game.registerKey(key, dispatcher);
      game.add(dispatcher);
    }
  }
}
