import 'package:flame/src/components/core/component.dart';
import 'package:meta/meta.dart';

/// Base class for a variety of input events, such as tap events, drag events,
/// keyboard events, etc.
///
/// This base class offers only simple common functionality; please see the
/// concrete [Event] subclasses for the information about each individual event
/// and the circumstances when they occur.
///
/// The type parameter [R] represents the type of the original Flutter raw event
/// that triggered this Flame event.
abstract class Event<R> {
  /// The original Flutter raw event that triggered this Flame event.
  R raw;

  /// Flag that can be used to indicate that the event was handled by one of the
  /// components.
  ///
  /// This flag is neither set nor read by Flame. Instead, it can be set by the
  /// user in a component that handles an event, and then read by the user in a
  /// different component, or at the root Game level.
  bool handled = false;

  /// If this flag is false (default), the event will be delivered to the first
  /// component that can handle it. If that component sets this flag to true,
  /// the event will propagate further down the component tree to other eligible
  /// components.
  bool continuePropagation = false;

  Event({required this.raw});

  @internal
  void deliverToComponents<T extends Component>(
    Component rootComponent,
    void Function(T component) eventHandler,
  ) {
    for (final child
        in rootComponent
            .descendants(reversed: true, includeSelf: true)
            .whereType<T>()) {
      continuePropagation = false;
      eventHandler(child);
      if (!continuePropagation) {
        break;
      }
    }
  }
}
