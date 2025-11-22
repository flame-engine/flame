import 'package:flame/extensions.dart';
import 'package:flame/src/events/messages/displacement_event.dart';
import 'package:flutter/gestures.dart';

/// Event propagated through the Flame engine when the user updates a scale
/// (pinch/zoom/rotate) gesture on the game canvas.
class ScaleUpdateEvent extends DisplacementEvent<ScaleUpdateDetails> {
  ScaleUpdateEvent(
    this.pointerId,
    super.game,
    ScaleUpdateDetails details,
  ) : scale = details.scale,
      horizontalScale = details.horizontalScale,
      verticalScale = details.verticalScale,
      rotation = details.rotation,
      pointerCount = details.pointerCount,
      focalPointDelta = details.focalPointDelta.toVector2(),
      timestamp = details.sourceTimeStamp ?? Duration.zero,
      super(
        raw: details,
        deviceStartPosition: details.focalPoint.toVector2(),
        deviceEndPosition:
            details.focalPoint.toVector2() +
            details.focalPointDelta.toVector2(),
      );

  /// Unique identifier of this scale gesture (Flame-level)
  final int pointerId;

  /// The instantaneous 2D scale factor (global)
  final double scale;

  /// Horizontal-only scale factor
  final double horizontalScale;

  /// Vertical-only scale factor
  final double verticalScale;

  /// Rotation delta in radians
  final double rotation;

  /// Number of fingers detected during this update
  final int pointerCount;

  /// Movement of the pinch center since last frame
  final Vector2 focalPointDelta;

  /// Timestamp for ordering/debugging
  final Duration timestamp;

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
