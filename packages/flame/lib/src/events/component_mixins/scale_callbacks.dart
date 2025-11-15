import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flutter/foundation.dart';

mixin ScaleCallbacks on Component {
  void onScaleStart(ScaleStartEvent event) {}
  void onScaleUpdate(ScaleUpdateEvent event) {}
  void onScaleEnd(ScaleEndEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const ScaleDispatcherKey()) == null) {
      final dispatcher = ScaleDispatcher();
      game.registerKey(const ScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
