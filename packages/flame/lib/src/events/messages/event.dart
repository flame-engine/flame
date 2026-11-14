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
abstract class Event<R>({
  /// The original Flutter raw event that triggered this Flame event.
  required var R raw,
}) {
  /// Whether the event should propagate further down the component tree to
  /// other eligible components after the current one.
  ///
  /// It is reset before each component receives the event. For most events it
  /// is reset to false, so only the first component that can handle the event
  /// receives it unless that component sets this flag to true. Events that
  /// are delivered to every eligible component, such as scroll and keyboard
  /// events, reset it to true instead, and a component can set it to false to
  /// stop them.
  bool continuePropagation = false;

  @internal
  void deliverToComponents<T extends Component>(
    Component rootComponent,
    void Function(T component) eventHandler, {
    bool deliverToAll = false,
  }) {
    rootComponent.propagateToChildren<T>(
      (component) {
        continuePropagation = deliverToAll;
        eventHandler(component);
        return continuePropagation;
      },
      includeSelf: true,
    );
  }
}
