import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/flame_game_mixins/pointer_move_dispatcher.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// pointer movement events.
mixin PointerMoveCallbacks on Component {
  void onPointerMoveEvent(PointerMoveEvent event) {}

  void onPointerMoveStopEvent(PointerMoveEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findGame()! as FlameGame;
    const key = MouseMoveDispatcherKey();
    if (game.findByKey(key) == null) {
      final dispatcher = PointerMoveDispatcher();
      game.registerKey(key, dispatcher);
      game.add(dispatcher);
    }
  }
}
