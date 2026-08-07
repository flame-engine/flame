import 'package:flame/components.dart';
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
