import 'package:flame/experimental.dart';
import 'package:flame/src/components/component.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// Base class for events that originate at some point on the screen. These
/// include: tap events, drag events, scale events, etc.
///
/// This class includes properties that describe the position where the event
/// has occurred.
abstract class PositionEvent extends Event {
  PositionEvent({required this.canvasPosition, required this.devicePosition});

  /// Event position in the coordinate space of the game widget, i.e. relative
  /// to the game canvas.
  ///
  /// This could be considered the Flame-level global position.
  final Vector2 canvasPosition;

  /// Event position in the coordinate space of the device -- either the phone,
  /// or the browser window, or the app.
  ///
  /// If the game runs in a full-screen mode, then this would be equal to the
  /// [canvasPosition]. Otherwise, the [devicePosition] is the Flutter-level
  /// global position.
  final Vector2 devicePosition;

  /// Event position in the local coordinate space of the current component.
  ///
  /// This property is only accessible when the event is being propagated to
  /// the components via [deliverAtPoint]. It is an error to try to read this
  /// property at other times.
  Vector2 get localPosition => renderingTrace.last;

  /// The stacktrace of coordinates of the event within the components in their
  /// rendering order.
  final List<Vector2> renderingTrace = [];

  /// Sends the event to components of type <T> that are currently rendered at
  /// the [canvasPosition].
  @internal
  void deliverAtPoint<T extends Component>({
    required Component rootComponent,
    required void Function(T component) eventHandler,
    bool deliverToAll = false,
  }) {
    for (final child in rootComponent
        .componentsAtPoint(canvasPosition, renderingTrace)
        .whereType<T>()) {
      continuePropagation = deliverToAll;
      eventHandler(child);
      if (!continuePropagation) {
        CameraComponent.currentCameras.clear();
        break;
      }
    }
  }
}
