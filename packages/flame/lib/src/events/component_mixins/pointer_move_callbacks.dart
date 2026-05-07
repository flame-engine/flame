import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// pointer movement events.
///
/// This callback uses [PointerMoveDispatcher] to route events.
mixin PointerMoveCallbacks on Component {
  void onPointerMove(PointerMoveEvent event) {}

  void onPointerMoveStop(PointerMoveEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    PointerMoveDispatcher.addDispatcher(this);
  }
}
