import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// Mixin for components that respond to scale (pinch/zoom/rotate) gestures.
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
    MultiDragScaleDispatcher.addDispatcher(
      this,
      hasDrag: false,
      hasScale: true,
    );
    findRootGame()?.adjustPointerEventHandlerCount(1);
  }

  @override
  @mustCallSuper
  void onRemove() {
    findRootGame()?.adjustPointerEventHandlerCount(-1);
    MultiDragScaleDispatcher.removeDispatcher(
      this,
      hasDrag: false,
      hasScale: true,
    );
    super.onRemove();
  }
}
