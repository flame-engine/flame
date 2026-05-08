import 'package:flame/src/events/messages/event.dart';
import 'package:flame/src/events/messages/tertiary_tap_down_event.dart';

/// The event propagated through the Flame engine when a tertiary tap
/// (i.e. middle mouse button click) on a component is cancelled.
///
/// This event may occur for several reasons, such as:
///  - a tertiary tap was converted into a drag event (for a game where
///    tertiary drag events are enabled);
///  - a tertiary tap was cancelled on the game widget itself -- for example,
///    if another app came into the foreground, or device turned off, etc;
///  - a tertiary tap was cancelled on a particular component because that
///    component has moved away from the point of contact.
///
/// The [TertiaryTapCancelEvent] will only occur if there was a previous
/// [TertiaryTapDownEvent].
class TertiaryTapCancelEvent extends Event<void> {
  TertiaryTapCancelEvent() : super(raw: null);

  @override
  String toString() => 'TertiaryTapCancel()';
}
