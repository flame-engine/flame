import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/src/camera/behaviors/bounded_position_behavior.dart';
import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/parent_is_a.dart';
import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame/src/experimental/geometry/shapes/polygon.dart';
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
      // A circle is a rounded rectangle whose radius is half of its size. It
      // looks the same at any angle, so the region is calculated for the
      // viewport before it's rotated, and is then rotated with the viewport,
      // which keeps it exact.
      //
      // The exact region is where four copies of the circle overlap, each
      // moved by the offset from one corner of the viewport to its center,
      // since each copy holds the positions where that corner stays within
      // the circle. It isn't a circle itself: it has a pointed end wherever
      // two of the copies meet. The polygon from _roundedRectangleRegion is
      // within a fraction of a unit of it. If the region ever needs to be
      // exact, or cheaper to check every frame, it could be a dedicated Shape
      // for that overlap instead: containsPoint would then be four distance
      // checks, and nearestPoint the nearest point on the four arcs or on
      // the points where they meet.
      final radius = shape.radius;
      final zoom = parent.zoom;
      return _roundedRectangleRegion(
        center,
        radius - viewport.virtualSize.x / (2 * zoom),
        radius - viewport.virtualSize.y / (2 * zoom),
        radius,
        angle: parent.angle,
      );
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
      final radius = shape.radius;
      if (halfWidth >= radius && halfHeight >= radius) {
        // Shrinking the rounded rectangle while keeping its radius is exact as
        // long as the result is large enough to fit the radius.
        return RoundedRectangle.fromLTRBR(
          center.x - halfWidth,
          center.y - halfHeight,
          center.x + halfWidth,
          center.y + halfHeight,
          radius,
        );
      }
      if (halfWidth > 0 && halfHeight > 0) {
        return _roundedRectangleRegion(center, halfWidth, halfHeight, radius);
      }
      return Rectangle.fromLTRB(
        center.x - halfWidth,
        center.y - halfHeight,
        center.x + halfWidth,
        center.y + halfHeight,
      );
    }
    return shape;
  }

  /// The number of edges that approximate each rounded corner of the region
  /// calculated by [_roundedRectangleRegion].
  static const _cornerSegments = 16;

  /// Calculates the region for a [RoundedRectangle] whose radius doesn't fit
  /// into the shrunk rectangle, i.e. when [halfWidth] or [halfHeight] is
  /// smaller than the [radius], which includes a [Circle].
  ///
  /// The corners of the viewport have to stay within the rounded corners of
  /// the bounds, so the region is limited by arcs with the same [radius]
  /// around the corners of a rectangle that is [halfWidth] - [radius] by
  /// [halfHeight] - [radius] in half-size, at least one of which is negative.
  /// The arcs are approximated by a polygon with its vertices on them, which
  /// lies within the exact region since that region is convex. The region is
  /// rotated by [angle] around the [center].
  Shape _roundedRectangleRegion(
    Vector2 center,
    double halfWidth,
    double halfHeight,
    double radius, {
    double angle = 0,
  }) {
    final arcCenterX = halfWidth - radius;
    final arcCenterY = halfHeight - radius;
    // The part of each arc that lies between the horizontal and the vertical
    // line through the center of the region.
    final startAngle = arcCenterY < 0
        ? asin(min(1.0, -arcCenterY / radius))
        : 0.0;
    final endAngle = arcCenterX < 0
        ? acos(min(1.0, -arcCenterX / radius))
        : pi / 2;
    if (!(endAngle - startAngle >= 1e-9)) {
      // The viewport only fits at the center, if at all.
      return Rectangle.fromLTRB(center.x, center.y, center.x, center.y);
    }

    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    final vertices = <Vector2>[];
    void addVertex(double x, double y) {
      final vertex = Vector2(
        center.x + x * cosAngle - y * sinAngle,
        center.y + x * sinAngle + y * cosAngle,
      );
      if (vertices.isEmpty || vertices.last.distanceToSquared(vertex) > 1e-9) {
        vertices.add(vertex);
      }
    }

    // Go around the corners, so that the arcs of neighboring corners meet.
    const corners = [(1.0, 1.0, false), (-1.0, 1.0, true)];
    for (final (signX, signY, isReversed) in [
      ...corners,
      for (final (signX, signY, isReversed) in corners)
        (-signX, -signY, isReversed),
    ]) {
      for (var i = 0; i <= _cornerSegments; i++) {
        final t = (isReversed ? _cornerSegments - i : i) / _cornerSegments;
        final angle = startAngle + (endAngle - startAngle) * t;
        addVertex(
          signX * (arcCenterX + radius * cos(angle)),
          signY * (arcCenterY + radius * sin(angle)),
        );
      }
    }
    if (vertices.first.distanceToSquared(vertices.last) <= 1e-9) {
      vertices.removeLast();
    }
    return Polygon(vertices);
  }
}
