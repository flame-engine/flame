import 'dart:ui';

import 'package:flame/components.dart'
    show CameraComponent, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flutter/foundation.dart';

/// The outline, anchor and axes of a [PositionComponent] in the canvas space
/// of the game, as seen through a single camera.
///
/// The outline is given by its four [corners] rather than by a rectangle, so
/// that rotations, scaling and flips of the component and its ancestors are
/// all represented.
@immutable
class const GizmoGeometry({
  required final List<Offset> corners,
  required final Offset anchor,
  required final Offset xAxis,
  required final Offset yAxis,
}) {
  /// The geometry of [component] for each camera that renders it.
  static List<GizmoGeometry> of(PositionComponent component) {
    return [
      for (final camera in camerasFor(component)) ?_compute(component, camera),
    ];
  }

  static GizmoGeometry? _compute(
    PositionComponent component,
    CameraComponent? camera,
  ) {
    Offset? map(double x, double y) {
      final point = localToCanvas(component, Vector2(x, y), camera: camera);
      return point == null ? null : Offset(point.x, point.y);
    }

    final width = component.size.x;
    final height = component.size.y;
    final anchorX = component.anchor.x * width;
    final anchorY = component.anchor.y * height;
    final topLeft = map(0, 0);
    final topRight = map(width, 0);
    final bottomRight = map(width, height);
    final bottomLeft = map(0, height);
    final anchor = map(anchorX, anchorY);
    final xEnd = map(anchorX + 1, anchorY);
    final yEnd = map(anchorX, anchorY + 1);
    if (topLeft == null ||
        topRight == null ||
        bottomRight == null ||
        bottomLeft == null ||
        anchor == null ||
        xEnd == null ||
        yEnd == null) {
      return null;
    }
    return GizmoGeometry(
      corners: [topLeft, topRight, bottomRight, bottomLeft],
      anchor: anchor,
      xAxis: _direction(xEnd - anchor),
      yAxis: _direction(yEnd - anchor),
    );
  }

  static Offset _direction(Offset offset) {
    final distance = offset.distance;
    return distance == 0 ? Offset.zero : offset / distance;
  }

  @override
  bool operator ==(Object other) =>
      other is GizmoGeometry &&
      listEquals(corners, other.corners) &&
      anchor == other.anchor &&
      xAxis == other.xAxis &&
      yAxis == other.yAxis;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(corners), anchor, xAxis, yAxis);
}
