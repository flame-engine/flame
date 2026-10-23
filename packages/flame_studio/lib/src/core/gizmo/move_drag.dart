import 'package:flame/components.dart'
    show CameraComponent, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';

/// Moves a [component] by dragging one of the handles of its gizmo.
///
/// Drags are measured in the canvas space of the game, and converted into the
/// space of the component's parent, where its position lives. The conversion
/// is captured when the drag starts, so that the component follows the pointer
/// even when the drag moves the camera, for example a camera that follows the
/// component.
class MoveDrag._(
  final PositionComponent component,
  final GizmoHandle handle,
  this._startPosition,
  this._inverse,
  this._axis,
) {
  final Vector2 _startPosition;

  /// The inverse of the linear part of the parent-to-canvas transform, as the
  /// columns `(a, b)` and `(c, d)`.
  final (double, double, double, double) _inverse;

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
    final parent = component.parent;
    if (parent == null) {
      return null;
    }
    final origin = localToCanvas(parent, Vector2.zero(), camera: camera);
    final unitX = localToCanvas(parent, Vector2(1, 0), camera: camera);
    final unitY = localToCanvas(parent, Vector2(0, 1), camera: camera);
    if (origin == null || unitX == null || unitY == null) {
      return null;
    }
    final column1 = unitX - origin;
    final column2 = unitY - origin;
    final determinant = column1.x * column2.y - column2.x * column1.y;
    if (determinant.abs() < 1e-12) {
      return null;
    }
    final inverse = (
      column2.y / determinant,
      -column1.y / determinant,
      -column2.x / determinant,
      column1.x / determinant,
    );

    Vector2? axis;
    if (handle != GizmoHandle.free) {
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
      handle,
      component.position.clone(),
      inverse,
      axis,
    );
  }

  /// Moves the component by [canvasDelta], which is the distance between the
  /// start of the drag and the current pointer position in canvas space.
  void update(Vector2 canvasDelta) {
    final (a, b, c, d) = _inverse;
    var delta = Vector2(
      a * canvasDelta.x + c * canvasDelta.y,
      b * canvasDelta.x + d * canvasDelta.y,
    );
    final axis = _axis;
    if (axis != null) {
      delta = axis * delta.dot(axis);
    }
    component.position = _startPosition + delta;
  }

  /// Moves the component back to where it was when the drag started.
  void cancel() {
    component.position = _startPosition;
  }
}
