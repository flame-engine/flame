import 'package:flame/components.dart'
    show CameraComponent, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_drag.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';

/// Moves a [component] by dragging one of the handles of its gizmo.
///
/// The drag is converted into the space of the component's parent, where its
/// position lives. Dragging an axis handle only moves the component along that
/// axis. Snapping rounds the distance moved to whole units.
class MoveDrag._(
  final PositionComponent component,
  this._startPosition,
  this._parentToCanvas,
  this._axis,
) implements GizmoDrag {
  final Vector2 _startPosition;
  final ParentToCanvas _parentToCanvas;

  /// The direction of the dragged axis in the parent space, or null when the
  /// drag is not constrained to an axis.
  final Vector2? _axis;

  /// Starts dragging [handle] of [component], as seen through [camera].
  ///
  /// Returns null when the component's parent space can't be mapped to the
  /// canvas, or is degenerate (for example, scaled to zero).
  static MoveDrag? start(
    PositionComponent component,
    GizmoHandle handle, {
    CameraComponent? camera,
  }) {
    final parentToCanvas = ParentToCanvas.of(component, camera: camera);
    if (parentToCanvas == null) {
      return null;
    }
    Vector2? axis;
    if (handle == GizmoHandle.x || handle == GizmoHandle.y) {
      final localAxis = handle == GizmoHandle.x ? Vector2(1, 0) : Vector2(0, 1);
      axis =
          component.positionOf(localAxis) -
          component.positionOf(Vector2.zero());
      if (axis.length2 == 0) {
        return null;
      }
      axis.normalize();
    }
    return MoveDrag._(
      component,
      component.position.clone(),
      parentToCanvas,
      axis,
    );
  }

  @override
  void update(Vector2 canvasDelta, {bool snap = false}) {
    var delta = _parentToCanvas.canvasToParent(canvasDelta);
    final axis = _axis;
    if (axis != null) {
      delta = axis * delta.dot(axis);
    }
    if (snap) {
      delta.setValues(
        delta.x.roundToDouble(),
        delta.y.roundToDouble(),
      );
    }
    component.position = _startPosition + delta;
  }

  @override
  void cancel() {
    component.position = _startPosition;
  }
}
