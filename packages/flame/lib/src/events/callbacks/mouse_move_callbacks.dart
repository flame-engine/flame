import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// mouse movement events.
///
/// This callback uses [MouseMoveDispatcher] to route events.
mixin MouseMoveCallbacks on Component implements PointerInputCallbacks {
  void onMouseMove(MouseMoveEvent event) {}

  void onMouseMoveStop(MouseMoveEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    MouseMoveDispatcher.addDispatcher(this);
  }
}
