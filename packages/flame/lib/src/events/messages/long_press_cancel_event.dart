import 'package:flame/src/events/messages/event.dart';

/// The event propagated through the Flame engine when a long press gesture
/// is cancelled before completing.
///
/// This may happen if the pointer moves too far before the long press
/// duration elapses, or if the gesture is otherwise interrupted.
class LongPressCancelEvent extends Event<void> {
  LongPressCancelEvent(this.pointerId) : super(raw: null);

  /// The id of the gesture that was cancelled.
  final int pointerId;

  @override
  String toString() => 'LongPressCancelEvent(pointerId: $pointerId)';
}
