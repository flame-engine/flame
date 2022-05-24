import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class PositionEvent extends Event {
  PositionEvent({required this.canvasPosition, required this.devicePosition});

  final Vector2 canvasPosition;

  final Vector2 devicePosition;

  final List<Vector2> positionStacktrace = [];

  Vector2 get localPosition => positionStacktrace.last;

  void deliverToComponentsAtPoint<T extends Component, E extends Event>(
    Component root,
    void Function(T, E) handler,
  ) {
    assert(this is E);
    for (final child in root
        .componentsAtPoint(canvasPosition, positionStacktrace)
        .whereType<T>()) {
      continuePropagation = false;
      handler(child, this as E);
      if (!continuePropagation) {
        break;
      }
    }
  }
}
