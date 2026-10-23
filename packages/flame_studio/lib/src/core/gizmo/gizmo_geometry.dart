import 'dart:ui';

import 'package:flame/components.dart'
    show CameraComponent, PositionComponent, Vector2;
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flutter/foundation.dart';

/// The parts of a gizmo that can be dragged.
enum GizmoHandle() {
  /// The arrow of the local x axis, which moves along that axis.
  x,

  /// The arrow of the local y axis, which moves along that axis.
  y,

  /// The square between the axes, which moves freely.
  free,
}

/// The outline, anchor and axes of a [PositionComponent] in the canvas space
/// of the game, as seen through a single [camera].
///
/// The outline is given by its four [corners] rather than by a rectangle, so
/// that rotations, scaling and flips of the component and its ancestors are
/// all represented. The handles have a fixed size in canvas space, regardless
/// of the size and zoom level of the component.
@immutable
class const GizmoGeometry({
  required final List<Offset> corners,
  required final Offset anchor,
  required final Offset xAxis,
  required final Offset yAxis,
  final CameraComponent? camera,
}) {
  static const double axisLength = 40.0;
  static const double freeHandleStart = 8.0;
  static const double freeHandleEnd = 18.0;

  /// How far from a handle, in logical pixels, a pointer may be to grab it.
  static const double handleTolerance = 6.0;

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
      camera: camera,
    );
  }

  static Offset _direction(Offset offset) {
    final distance = offset.distance;
    return distance == 0 ? Offset.zero : offset / distance;
  }

  Offset get xAxisEnd => anchor + xAxis * axisLength;

  Offset get yAxisEnd => anchor + yAxis * axisLength;

  /// The corners of the square handle that moves the component freely.
  List<Offset> get freeHandleCorners => [
    anchor + xAxis * freeHandleStart + yAxis * freeHandleStart,
    anchor + xAxis * freeHandleEnd + yAxis * freeHandleStart,
    anchor + xAxis * freeHandleEnd + yAxis * freeHandleEnd,
    anchor + xAxis * freeHandleStart + yAxis * freeHandleEnd,
  ];

  /// The handle at [point], which is in canvas space, if any.
  GizmoHandle? handleAt(Offset point) {
    final offset = point - anchor;
    // The coordinates of the point along each axis, and its distance from it.
    final alongX = _dot(offset, xAxis);
    final alongY = _dot(offset, yAxis);
    final fromX = _cross(xAxis, offset).abs();
    final fromY = _cross(yAxis, offset).abs();

    const tolerance = handleTolerance;
    bool isWithin(double value, double start, double end) =>
        value >= start - tolerance / 2 && value <= end + tolerance / 2;

    if (xAxis != Offset.zero &&
        yAxis != Offset.zero &&
        isWithin(alongX, freeHandleStart, freeHandleEnd) &&
        isWithin(alongY, freeHandleStart, freeHandleEnd)) {
      return GizmoHandle.free;
    }
    final onX =
        xAxis != Offset.zero &&
        fromX <= tolerance &&
        isWithin(alongX, 0, axisLength);
    final onY =
        yAxis != Offset.zero &&
        fromY <= tolerance &&
        isWithin(alongY, 0, axisLength);
    if (onX && onY) {
      return fromX <= fromY ? GizmoHandle.x : GizmoHandle.y;
    }
    return onX ? GizmoHandle.x : (onY ? GizmoHandle.y : null);
  }

  /// Whether [point], which is in canvas space, is inside of the outline.
  bool containsPoint(Offset point) {
    return (Path()..addPolygon(corners, true)).contains(point);
  }

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

  static double _cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;

  @override
  bool operator ==(Object other) =>
      other is GizmoGeometry &&
      listEquals(corners, other.corners) &&
      anchor == other.anchor &&
      xAxis == other.xAxis &&
      yAxis == other.yAxis &&
      camera == other.camera;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(corners), anchor, xAxis, yAxis, camera);
}
