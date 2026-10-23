import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/gizmo_drag.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/snap_settings.dart';

/// Scales a [component] by dragging the handles of its gizmo.
///
/// The axis handles scale along their axis and the square between them scales
/// both axes uniformly. Dragging a handle away from the anchor by the length of
/// an axis handle doubles the scale. Snapping rounds the scale along the
/// dragged axes to multiples of [snapStep].
class ScaleDrag._(
  final PositionComponent component,
  final GizmoHandle handle,
  final double snapStep,
  this._startScale,
  this._direction,
) implements GizmoDrag {
  final Vector2 _startScale;

  /// The direction in canvas space in which dragging grows the component.
  final Offset _direction;

  /// Starts dragging [handle] of [component], whose gizmo is [geometry].
  ///
  /// Returns null for handles that don't scale, or when the direction of the
  /// handle is degenerate.
  static ScaleDrag? start(
    PositionComponent component,
    GizmoHandle handle,
    GizmoGeometry geometry, {
    required double snapStep,
  }) {
    final direction = switch (handle) {
      GizmoHandle.x => geometry.xAxis,
      GizmoHandle.y => geometry.yAxis,
      GizmoHandle.free => geometry.xAxis + geometry.yAxis,
      GizmoHandle.ring => Offset.zero,
    };
    if (direction == Offset.zero) {
      return null;
    }
    return ScaleDrag._(
      component,
      handle,
      snapStep,
      component.scale.clone(),
      direction / direction.distance,
    );
  }

  @override
  void update(Vector2 canvasDelta, {bool snap = false}) {
    final distance =
        canvasDelta.x * _direction.dx + canvasDelta.y * _direction.dy;
    final factor = 1 + distance / GizmoGeometry.axisLength;
    double scaled(double value) {
      final result = value * factor;
      return snap ? snapTo(result, snapStep) : result;
    }

    component.scale = Vector2(
      handle == GizmoHandle.y ? _startScale.x : scaled(_startScale.x),
      handle == GizmoHandle.x ? _startScale.y : scaled(_startScale.y),
    );
  }

  @override
  void cancel() {
    component.scale = _startScale;
  }
}
