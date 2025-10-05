import 'package:flame/src/events/messages/event.dart';
import 'package:flame/src/events/messages/secondary_tap_down_event.dart';

/// The event propagated through the Flame engine when a secondary tap
/// (i.e. right mouse button click) on a component is cancelled.
///
/// This event may occur for several reasons, such as:
///  - a secondary tap was converted into a drag event (for a game where
///    secondary drag events are enabled);
///  - a secondary tap was cancelled on the game widget itself -- for example,
///    if another app came into the foreground, or device turned off, etc;
///  - a secondary tap was cancelled on a particular component because that
///    component has moved away from the point of contact.
///
/// The [SecondaryTapCancelEvent] will only occur if there was a previous
/// [SecondaryTapDownEvent].
class SecondaryTapCancelEvent extends Event<void> {
  SecondaryTapCancelEvent() : super(raw: null);

  @override
  String toString() => 'SecondaryTapCancel()';
}
