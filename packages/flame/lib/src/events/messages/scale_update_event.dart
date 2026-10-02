import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when the user updates a scale
/// (pinch/zoom/rotate) gesture on the game canvas.
class ScaleUpdateEvent(
  /// Unique identifier of this scale gesture (Flame-level)
  final int pointerId,
  super.game,
  ScaleUpdateDetails details,
) extends DisplacementEvent<ScaleUpdateDetails> {
  this
    : super(
        raw: details,
        deviceStartPosition: details.focalPoint.toVector2(),
        deviceEndPosition:
            details.focalPoint.toVector2() +
            details.focalPointDelta.toVector2(),
      );

  /// The instantaneous 2D scale factor (global)
  final double scale = details.scale;

  /// Horizontal-only scale factor
  final double horizontalScale = details.horizontalScale;

  /// Vertical-only scale factor
  final double verticalScale = details.verticalScale;

  /// Rotation delta in radians
  final double rotation = details.rotation;

  /// Number of fingers detected during this update
  final int pointerCount = details.pointerCount;

  /// Movement of the pinch center since last frame
  final Vector2 focalPointDelta = details.focalPointDelta.toVector2();

  /// Timestamp for ordering/debugging
  final Duration timestamp = details.sourceTimeStamp ?? Duration.zero;

  @override
  String toString() =>
      'ScaleUpdateEvent('
      'pointerId: $pointerId, '
      'scale: $scale, '
      'hScale: $horizontalScale, '
      'vScale: $verticalScale, '
      'rotation: $rotation, '
      'pointerCount: $pointerCount, '
      'focalPointDelta: $focalPointDelta, '
      'deviceStartPosition: $deviceStartPosition, '
      'deviceEndPosition: $deviceEndPosition, '
      'localDelta: $localDelta, '
      'timestamp: $timestamp'
      ')';
}
