import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/camera/behaviors/bounded_position_behavior.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame/src/experimental/geometry/shapes/rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/rounded_rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';

/// This behavior ensures that none of the viewport can go outside
/// of the bounds, when it is false only the viewfinder anchor is considered.
/// Note that it only works with [Rectangle], [RoundedRectangle] and [Circle]
/// shapes.
class ViewportAwareBoundsBehavior({
  required var Shape _boundsShape,
  super.key,
}) extends Component with ParentIsA<Viewfinder> {
  /// The size of the world region visible through the viewport that the
  /// current bounds were calculated for.
  final Vector2 _visibleWorldSize = Vector2.zero();
  final Vector2 _currentVisibleWorldSize = Vector2.zero();

  @override
  void onLoad() {
    parent.transform.scale.addListener(_updateCameraBoundsIfNeeded);
    viewport.transform.scale.addListener(_updateCameraBoundsIfNeeded);
  }

  @override
  void onMount() {
    super.onMount();
    _updateCameraBounds();
  }

  @override
  void onRemove() {
    viewport.transform.scale.removeListener(_updateCameraBoundsIfNeeded);
    parent.transform.scale.removeListener(_updateCameraBoundsIfNeeded);
  }

  /// Returns the bounds that do not take the viewport into account.
  /// These bounds are automatically updated when [CameraComponent.setBounds]
  /// is being called.
  Shape get boundsShape => _boundsShape;

  /// Changes the original camera bounds.
  /// This setter is used when you call [CameraComponent.setBounds].
  set boundsShape(Shape boundsShape) {
    _boundsShape = boundsShape;
    _updateCameraBounds();
  }

  /// Returns the camera viewport.
  Viewport get viewport => parent.camera.viewport;

  /// Calls [_updateCameraBounds] if the size of the visible world region
  /// differs from the one that the current bounds were calculated for.
  void _updateCameraBoundsIfNeeded() {
    _computeVisibleWorldSize(_currentVisibleWorldSize);
    if (_currentVisibleWorldSize != _visibleWorldSize) {
      _updateCameraBounds();
    }
  }

  /// Triggers an update of the current camera bounds.
  void _updateCameraBounds() {
    _computeVisibleWorldSize(_visibleWorldSize);
    final boundedBehavior = parent.firstChild<BoundedPositionBehavior>();
    boundedBehavior?.bounds = _calculateViewportAwareBounds();
  }

  /// Computes the size of the axis-aligned box around the world region that
  /// is visible through the viewport, taking the zoom and angle of the
  /// viewfinder into account.
  void _computeVisibleWorldSize(Vector2 output) {
    final viewportSize = viewport.virtualSize;
    final zoom = parent.zoom;
    final angle = parent.angle;
    if (angle == 0) {
      output.setValues(viewportSize.x / zoom, viewportSize.y / zoom);
    } else {
      final cosAngle = cos(angle).abs();
      final sinAngle = sin(angle).abs();
      output.setValues(
        (viewportSize.x * cosAngle + viewportSize.y * sinAngle) / zoom,
        (viewportSize.x * sinAngle + viewportSize.y * cosAngle) / zoom,
      );
    }
  }

  /// Calculates the region within which the viewfinder's position has to stay
  /// so that none of the viewport goes outside of [_boundsShape].
  ///
  /// If the visible region is larger than the bounds along an axis, the
  /// returned region collapses to the center of the bounds along that axis.
  ///
  /// It returns the [_boundsShape] if the shape is not supported.
  Shape _calculateViewportAwareBounds() {
    final shape = _boundsShape;
    final center = shape.center;
    if (shape is Circle) {
      // The rectangular viewport is fully within the circle only when all of
      // its corners are, so the viewfinder has to stay at least half of the
      // visible region's diagonal away from the circle's edge.
      final halfDiagonal = viewport.virtualSize.length / (2 * parent.zoom);
      return Circle(center, max(0, shape.radius - halfDiagonal));
    }

    final aabb = shape.aabb;
    final halfWidth = max(
      0.0,
      (aabb.max.x - aabb.min.x - _visibleWorldSize.x) / 2,
    );
    final halfHeight = max(
      0.0,
      (aabb.max.y - aabb.min.y - _visibleWorldSize.y) / 2,
    );
    if (shape is Rectangle) {
      return Rectangle.fromLTRB(
        center.x - halfWidth,
        center.y - halfHeight,
        center.x + halfWidth,
        center.y + halfHeight,
      );
    } else if (shape is RoundedRectangle) {
      // Shrinking the rounded rectangle while keeping its radius is exact as
      // long as the result is large enough to fit the radius; the constructor
      // reduces the radius otherwise.
      return RoundedRectangle.fromLTRBR(
        center.x - halfWidth,
        center.y - halfHeight,
        center.x + halfWidth,
        center.y + halfHeight,
        shape.radius,
      );
    }
    return shape;
  }
}
