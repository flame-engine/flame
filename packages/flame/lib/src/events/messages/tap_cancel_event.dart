import 'package:flame/src/events/messages/event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';

/// The event propagated through the Flame engine when a tap on a component is
/// cancelled.
///
/// This event may occur for several reasons, such as:
///  - a tap was converted into a drag event (for a game where drag events are
///    enabled);
///  - a tap was cancelled on the game widget itself -- for example if another
///    app came into the foreground, or device turned off, etc;
///  - a tap was cancelled on a particular component because that component has
///    moved away from the point of contact.
///
/// The [TapCancelEvent] will only occur if there was a previous [TapDownEvent].
class TapCancelEvent extends Event {
  TapCancelEvent(this.pointerId);

  /// The id of the event that has been cancelled. This id corresponds to the
  /// id of the previous [TapDownEvent].
  final int pointerId;

  @override
  String toString() => 'TapCancelEvent(pointerId: $pointerId)';
}
