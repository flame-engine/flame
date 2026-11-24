import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/foundation.dart';

/// {@template vertices_view_transform}
/// Maps the local coordinates of a polygon to the vertices canvas and
/// back, and finds the handles under a point of the canvas.
/// {@endtemplate}
@immutable
class const VerticesViewTransform({
  /// The canvas pixels per local unit.
  final double scale = 1,

  /// Where the local origin is on the canvas.
  final Offset offset = Offset.zero,
}) {
  /// {@macro vertices_view_transform}
  this;

  /// A transform that centers [vertices] in a canvas of [size], scaled down
  /// only if they don't fit within [padding] of its edges.
  factory fit(
    List<ComponentVertex> vertices,
    Size size, {
    double padding = 48,
  }) {
    final bounds = boundsOf(vertices);
    final available = Size(
      math.max(size.width - padding * 2, 1),
      math.max(size.height - padding * 2, 1),
    );
    final scale = [
      1.0,
      if (bounds.width > 0) available.width / bounds.width,
      if (bounds.height > 0) available.height / bounds.height,
    ].reduce(math.min);
    return VerticesViewTransform(
      scale: scale,
      offset: size.center(Offset.zero) - bounds.center * scale,
    );
  }

  /// This transform scaled by [zoom] around [center], a point of the
  /// canvas that stays where it is.
  VerticesViewTransform zoomed(double zoom, Offset center) {
    return VerticesViewTransform(
      scale: scale * zoom,
      offset: center - (center - offset) * zoom,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VerticesViewTransform &&
      other.scale == scale &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(scale, offset);

  /// The radius around a handle within which the pointer hits it.
  static const hitRadius = 10.0;

  /// The bounding box of [vertices], in local coordinates.
  static Rect boundsOf(List<ComponentVertex> vertices) {
    final xs = vertices.map((vertex) => vertex.x);
    final ys = vertices.map((vertex) => vertex.y);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  /// Where [vertex] is on the canvas.
  Offset toCanvas(ComponentVertex vertex) {
    return Offset(vertex.x, vertex.y) * scale + offset;
  }

  /// The vertex at [point] of the canvas, rounded to whole local units.
  ComponentVertex toLocal(Offset point) {
    final local = (point - offset) / scale;
    return ComponentVertex(local.dx.roundToDouble(), local.dy.roundToDouble());
  }

  /// The middle of the edge that starts at the vertex at [index], on the
  /// canvas.
  Offset midpointOf(List<ComponentVertex> vertices, int index) {
    final from = toCanvas(vertices[index]);
    final to = toCanvas(vertices[(index + 1) % vertices.length]);
    return Offset.lerp(from, to, 0.5)!;
  }

  /// The index of the vertex whose handle is at [point], if any. The
  /// closest one wins.
  int? vertexAt(List<ComponentVertex> vertices, Offset point) {
    return _closest(
      vertices.length,
      (index) => (toCanvas(vertices[index]) - point).distance,
    );
  }

  /// The index of the edge (by its first vertex) whose midpoint handle is
  /// at [point], if any.
  int? midpointAt(List<ComponentVertex> vertices, Offset point) {
    return _closest(
      vertices.length,
      (index) => (midpointOf(vertices, index) - point).distance,
    );
  }

  /// The index of the edge (by its first vertex) that passes near
  /// [point], if any.
  int? edgeNear(List<ComponentVertex> vertices, Offset point) {
    return _closest(vertices.length, (index) {
      final from = toCanvas(vertices[index]);
      final to = toCanvas(vertices[(index + 1) % vertices.length]);
      return _distanceToSegment(point, from, to);
    });
  }

  static int? _closest(int length, double Function(int index) distanceOf) {
    int? closest;
    var closestDistance = hitRadius;
    for (var index = 0; index < length; index++) {
      final distance = distanceOf(index);
      if (distance <= closestDistance) {
        closest = index;
        closestDistance = distance;
      }
    }
    return closest;
  }

  static double _distanceToSegment(Offset point, Offset from, Offset to) {
    final segment = to - from;
    final lengthSquared = segment.distanceSquared;
    if (lengthSquared == 0) {
      return (point - from).distance;
    }
    final delta = point - from;
    final t = ((delta.dx * segment.dx + delta.dy * segment.dy) / lengthSquared)
        .clamp(0.0, 1.0);
    return (point - (from + segment * t)).distance;
  }
}
