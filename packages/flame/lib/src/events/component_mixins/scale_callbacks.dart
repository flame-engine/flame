import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flutter/foundation.dart';

mixin ScaleCallbacks on Component {
  bool _isScaled = false;

  /// Returns true while the component is being scaled.
  bool get isScaled => _isScaled;

  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    _isScaled = true;
  }

  void onScaleUpdate(ScaleUpdateEvent event) {}

  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _isScaled = false;
  }

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
