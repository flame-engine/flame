import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class PositionEvent extends Event {
  PositionEvent({required this.canvasPosition, required this.devicePosition});

  final Vector2 canvasPosition;

  final Vector2 devicePosition;

  final List<Vector2> positionStacktrace = [];

  Vector2 get localPosition => positionStacktrace.last;

  void deliverAtPoint<T extends Component>({
    required Component rootComponent,
    required void Function(T component) eventHandler,
  }) {
    for (final child in rootComponent
        .componentsAtPoint(canvasPosition, positionStacktrace)
        .whereType<T>()) {
      continuePropagation = false;
      eventHandler(child);
      if (!continuePropagation) {
        break;
      }
    }
  }
}
