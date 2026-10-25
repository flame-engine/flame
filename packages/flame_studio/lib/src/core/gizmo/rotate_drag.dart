import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_drag.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/snap_settings.dart';

/// Rotates a [component] around its anchor by dragging the ring of its gizmo.
///
/// The component turns by the angle that the pointer sweeps around the anchor.
/// Snapping rounds the angle of the component to multiples of [snapStep],
/// which is in radians.
class RotateDrag._(
  final PositionComponent component,
  final double snapStep,
  this._startAngle,
  this._anchor,
  this._startPoint,
  this._direction,
) implements GizmoDrag {
  final double _startAngle;
  final Offset _anchor;
  final Offset _startPoint;

  /// 1 when rotations on the canvas match rotations of the component, and -1
  /// when the parent space is mirrored.
  final double _direction;

  /// Starts rotating [component], whose gizmo is [geometry], from
  /// [startPoint] in canvas space.
  ///
  /// Returns null when the component's parent space can't be mapped to the
  /// canvas, or when [startPoint] is at the anchor.
  static RotateDrag? start(
    PositionComponent component,
    GizmoGeometry geometry,
    Offset startPoint, {
    required double snapStep,
  }) {
    final parentToCanvas = ParentToCanvas.of(
      component,
      camera: geometry.camera,
    );
    if (parentToCanvas == null || startPoint == geometry.anchor) {
      return null;
    }
    return RotateDrag._(
      component,
      snapStep,
      component.angle,
      geometry.anchor,
      startPoint,
      parentToCanvas.isMirrored ? -1 : 1,
    );
  }

  @override
  void update(Vector2 canvasDelta, {bool snap = false}) {
    final point = _startPoint + Offset(canvasDelta.x, canvasDelta.y);
    if (point == _anchor) {
      return;
    }
    final sweep =
        (point - _anchor).direction - (_startPoint - _anchor).direction;
    var angle = _startAngle + _direction * sweep;
    if (snap) {
      angle = snapTo(angle, snapStep);
    }
    component.angle = angle;
  }

  @override
  void cancel() {
    component.angle = _startAngle;
  }
}
