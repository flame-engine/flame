import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user stops touching
/// the game canvas.
///
/// This is a [PositionEvent], where the position is the point where the touch
/// has last occurred.
///
/// The [TapUpEvent] will only occur if there was a previous [TapDownEvent].
class TapUpEvent(
  /// The id of the previous [TapDownEvent] to which this event corresponds.
  final int pointerId,
  super.game,
  TapUpDetails details,
) extends PositionEvent<TapUpDetails> {
  this
    : super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  final PointerDeviceKind deviceKind = details.kind;

  TapCancelEvent toTapCancel() => TapCancelEvent(pointerId);

  @override
  String toString() =>
      'TapUpEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointerId: $pointerId, deviceKind: $deviceKind)';
}
