import 'package:flame/components.dart'
    show CameraComponent, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_drag.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/snap_settings.dart';

/// Moves a [component] by dragging one of the handles of its gizmo.
///
/// The drag is converted into the space of the component's parent, where its
/// position lives. Dragging an axis handle only moves the component along that
/// axis.
///
/// Snapping places the component on a grid with cells of [snapStep] units in
/// the parent space. When dragging along an axis that isn't parallel to the
/// axes of the parent, the distance moved is snapped instead, so that the
/// component stays on the axis.
class MoveDrag._(
  final PositionComponent component,
  final double snapStep,
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
    required double snapStep,
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
      snapStep,
      component.position.clone(),
      parentToCanvas,
      axis,
    );
  }

  @override
  void update(Vector2 canvasDelta, {bool snap = false}) {
    final delta = _parentToCanvas.canvasToParent(canvasDelta);
    final axis = _axis;
    if (axis == null) {
      final position = _startPosition + delta;
      if (snap) {
        position.setValues(
          snapTo(position.x, snapStep),
          snapTo(position.y, snapStep),
        );
      }
      component.position = position;
      return;
    }
    var distance = delta.dot(axis);
    if (snap && _isParallel(axis.y)) {
      final x = snapTo(_startPosition.x + distance * axis.x, snapStep);
      component.position = Vector2(x, _startPosition.y);
      return;
    }
    if (snap && _isParallel(axis.x)) {
      final y = snapTo(_startPosition.y + distance * axis.y, snapStep);
      component.position = Vector2(_startPosition.x, y);
      return;
    }
    if (snap) {
      distance = snapTo(distance, snapStep);
    }
    component.position = _startPosition + axis * distance;
  }

  /// Whether an axis whose other coordinate is [otherCoordinate] is parallel
  /// to one of the axes of the parent.
  static bool _isParallel(double otherCoordinate) {
    return otherCoordinate.abs() < 1e-9;
  }

  @override
  void cancel() {
    component.position = _startPosition;
  }
}
