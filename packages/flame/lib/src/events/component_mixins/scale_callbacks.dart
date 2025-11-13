import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/multi_scale_dispatcher.dart';
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
    if (game.findByKey(const MultiScaleDispatcherKey()) == null) {
      final dispatcher = MultiScaleDispatcher();
      game.registerKey(const MultiScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
