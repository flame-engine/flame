import 'package:flame/components.dart';
import 'package:flame/src/events/messages/event.dart';
import 'package:meta/meta.dart';

/// A base event that includes a location context, i.e. a position or set of
/// positions in which the event happens.
///
/// The type parameter [C] is the generalization of the representation used to
/// describe the location instance, such as a [Vector2].
abstract class LocationContextEvent<C, R> extends Event<R> {
  /// The stacktrace of coordinates of the event within the components in their
  /// rendering order.
  ///
  /// This represents the stack of transformed versions of the same location
  /// context -- which represents the event point -- but in the coordinate space
  /// of each parent component until the root.
  final List<C> renderingTrace = [];

  LocationContextEvent({required super.raw});

  /// The context in the parent's coordinate space, containing start and end
  /// points.
  C? get parentContext {
    if (renderingTrace.length >= 2) {
      final lastIndex = renderingTrace.length - 1;
      return renderingTrace[lastIndex];
    } else {
      return null;
    }
  }

  @internal
  Iterable<Component> collectApplicableChildren({
    required Component rootComponent,
  });

  @internal
  void deliverAtPoint<T extends Component>({
    required Component rootComponent,
    required void Function(T component) eventHandler,
    bool deliverToAll = false,
  }) {
    final children = collectApplicableChildren(
      rootComponent: rootComponent,
    );
    for (final child in children.whereType<T>()) {
      continuePropagation = deliverToAll;
      eventHandler(child);
      if (!continuePropagation) {
        CameraComponent.currentCameras.clear();
        break;
      }
    }
  }
}
