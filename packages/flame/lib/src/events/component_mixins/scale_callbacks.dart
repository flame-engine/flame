import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flutter/foundation.dart';

/// This callback uses [ScaleDispatcher] to route events.
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
    ScaleDispatcher.addDispatcher(this);
  }
}
