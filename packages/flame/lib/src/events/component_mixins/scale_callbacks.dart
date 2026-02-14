import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flutter/foundation.dart';

mixin ScaleCallbacks on Component {
  bool _isScaling = false;

  /// Returns true while the component is being scaled.
  bool get isScaling => _isScaling;

  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    _isScaling = true;
  }

  void onScaleUpdate(ScaleUpdateEvent event) {}

  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _isScaling = false;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    // Skip if DragCallbacks will handle it
    if (this is DragCallbacks) {
      return;
    }

    final game = findRootGame()!;
    final scaleDispatcher = game.findByKey(const ScaleDispatcherKey());
    final multiDragDispatcher = game.findByKey(const MultiDragDispatcherKey());
    final multiDragScaleDispatcher = game.findByKey(
      const MultiDragScaleDispatcherKey(),
    );

    // If MultiDragScaleDispatcher exists, DragCallbacks already handled it
    if (multiDragScaleDispatcher != null) {
      return;
    }

    if (scaleDispatcher == null && multiDragDispatcher == null) {
      final dispatcher = ScaleDispatcher();
      game.registerKey(const ScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
    } else if (scaleDispatcher == null && multiDragDispatcher != null) {
      final dispatcher = MultiDragScaleDispatcher();
      game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
      (multiDragDispatcher as MultiDragDispatcher).markForRemoval();
    }
  }
}
