import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/camera/behaviors/bounded_position_behavior.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame/src/experimental/geometry/shapes/rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/rounded_rectangle.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';

/// This behavior ensures that the none of the viewport can go outside
/// of the bounds, when it is false only the viewfinder anchor is considered.
/// Note that it only works with [Rectangle], [RoundedRectangle] and [Circle]
/// shapes.
class ViewportAwareBoundsBehavior extends Component with ParentIsA<Viewfinder> {
  Shape _originalBounds;
  late Rect _visibleWorldRect;

  ViewportAwareBoundsBehavior({
    required Shape originalBounds,
  })  : _originalBounds = originalBounds;

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
  Shape get originalBounds => _originalBounds;

  /// Changes the original camera bounds.
  set originalBounds(Shape originalBounds) {
    _originalBounds = originalBounds;
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

  /// This method calculates adapts the [_originalBounds] so that none
  /// of the viewport can go outside of the bounds.
  /// It returns the [_originalBounds] if it fails to calculates new bounds.
  Shape _calculateViewportAwareBounds() {
    final worldSize = Vector2(
      _originalBounds.support(
          _originalBounds.nearestPoint(_originalBounds.center + Vector2(1, 0)),
      ).x,
      _originalBounds.support(
          _originalBounds.nearestPoint(_originalBounds.center + Vector2(0, 1)),
      ).y,
    );
    final halfViewportSize = viewport.size / 2;
    if (_originalBounds is Rectangle) {
      return Rectangle.fromCenter(
        center: _originalBounds.center,
        size: worldSize - halfViewportSize,
      );
    } else if (_originalBounds is RoundedRectangle) {
      final halfSize = (worldSize - halfViewportSize) / 2;
      return RoundedRectangle.fromPoints(
        _originalBounds.center - halfSize,
        _originalBounds.center + halfSize,
        (_originalBounds as RoundedRectangle).radius,
      );
    } else if (_originalBounds is Circle) {
      return Circle(
        _originalBounds.center,
        worldSize.x - max(halfViewportSize.x, halfViewportSize.y),
      );
    }
    return _originalBounds;
  }
}
