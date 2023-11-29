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
class ViewportAwareBoundsBehavior extends Component with ParentIsA<Viewfinder> {
  Shape _boundsShape;
  late Rect _visibleWorldRect;

  ViewportAwareBoundsBehavior({
    required Shape boundsShape,
  }) : _boundsShape = boundsShape;

  @override
  void onLoad() {
    _visibleWorldRect = parent.visibleWorldRect;
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

  /// Calls [_updateCameraBounds] if the [_visibleWorldRect] differs from
  /// viewfinder visible world rect.
  void _updateCameraBoundsIfNeeded() {
    if (_visibleWorldRect != parent.visibleWorldRect) {
      _updateCameraBounds();
    }
  }

  /// Triggers an update of the current camera bounds.
  void _updateCameraBounds() {
    _visibleWorldRect = parent.visibleWorldRect;
    final boundedBehavior = parent.firstChild<BoundedPositionBehavior>();
    boundedBehavior?.bounds = _calculateViewportAwareBounds();
  }

  /// This method calculates adapts the [_boundsShape] so that none
  /// of the viewport can go outside of the bounds.
  /// It returns the [_boundsShape] if it fails to calculates new bounds.
  Shape _calculateViewportAwareBounds() {
    final worldSize = Vector2(
      _boundsShape
          .support(
            _boundsShape.nearestPoint(
              _boundsShape.center + Vector2(1, 0),
            ),
          )
          .x,
      _boundsShape
          .support(
            _boundsShape.nearestPoint(
              _boundsShape.center + Vector2(0, 1),
            ),
          )
          .y,
    );
    final halfViewportSize = viewport.size / 2;
    if (_boundsShape is Rectangle) {
      return Rectangle.fromCenter(
        center: _boundsShape.center,
        size: worldSize - halfViewportSize,
      );
    } else if (_boundsShape is RoundedRectangle) {
      final halfSize = (worldSize - halfViewportSize) / 2;
      return RoundedRectangle.fromPoints(
        _boundsShape.center - halfSize,
        _boundsShape.center + halfSize,
        (_boundsShape as RoundedRectangle).radius,
      );
    } else if (_boundsShape is Circle) {
      return Circle(
        _boundsShape.center,
        worldSize.x - max(halfViewportSize.x, halfViewportSize.y),
      );
    }
    return _boundsShape;
  }
}
