import 'dart:math' show max, sqrt;
import 'dart:typed_data' show Float32List;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart' show Transform2D, Vector2;
import 'package:flame/src/cache/matrix_pool.dart' show pathTransform;

export 'dart:ui' show Path;

extension PathExtension on Path {
  Path transform32(Float32List matrix4) {
    return pathTransform(this, matrix4);
  }

  /// Returns a new [Path] with the given [size], which is scaled to
  /// to the current aspect ratio if [keepRatio] is true.
  Path resizeTo(Size size, {bool keepRatio = false}) {
    assert(
      size.width > 0 && size.height > 0,
      'Resizing with invalid size: $size',
    );
    final box = getBounds();
    final scale = Vector2(size.width / box.width, size.height / box.height);
    if (keepRatio) {
      final uniformScale = scale.x < scale.y ? scale.x : scale.y;
      scale.setValues(uniformScale, uniformScale);
    }
    final t = Transform2D()..scale = scale;
    return transform32(t.transformMatrix.storage);
  }

  /// Returns a new [Path] translated such that its `topLeft` is at zero.
  Path get toOrigin {
    final box = getBounds();
    final origin = box.topLeft;
    if (origin != .zero) {
      return shift(-origin);
    }
    return this;
  }

  /// Returns a new [Path] translated such that its `center` is at zero.
  Path get centered {
    final box = getBounds();
    final center = box.center;
    if (center != .zero) {
      return toOrigin.shift(-(box.size.toOffset() * 0.5));
    }
    return this;
  }
}

typedef PathMetricList = List<PathMetric>;
typedef OffsetList = List<Offset>;

extension PathContours on Path {
  /// Return a list of [PathMetric] objects, corresponding to the contours
  /// in this path.
  PathMetricList get contours {
    return computeMetrics().toList(growable: false);
  }

  /// Walk the contours of a [Path] and return them as a list of [Offset] lists.
  /// Each entry in the list corresponds to a given sub-contour.
  ///
  /// See [Contour.walkContour] for the [granularity] and [tolerance]
  /// parameters.
  List<OffsetList> walkContours([
    double granularity = 1.0,
    double? tolerance,
  ]) {
    return [
      for (final metric in computeMetrics())
        metric.walkContour(granularity, tolerance),
    ];
  }
}

extension Contour on PathMetric {
  /// The upper bound for the amount of sampling steps in a single contour.
  static const _maxSteps = 1 << 20;

  /// Walk a single contour of a [Path] and return it as an [Offset] list.
  ///
  /// The polyline is sampled at regular intervals along the path, then
  /// simplified using the RDP algorithm with the given [tolerance], which
  /// defaults to half of the [granularity] so that it follows the scale that
  /// the path is sampled at. This reduces vertex count while maintaining
  /// acceptable accuracy for hitbox geometry. A [tolerance] of zero only
  /// removes the samples that are on a line between their neighbors.
  ///
  /// The [granularity] parameter controls the amplitude of the sampling step:
  /// higher values produce fewer samples. It has to be a positive number, and
  /// a contour is never sampled in more than about a million steps.
  OffsetList walkContour([double granularity = 1.0, double? tolerance]) {
    assert(
      granularity.isFinite && granularity > 0,
      'The granularity has to be a positive number: $granularity',
    );
    assert(
      tolerance == null || (tolerance.isFinite && tolerance >= 0),
      'The tolerance can not be negative: $tolerance',
    );
    final validGranularity = granularity.isFinite && granularity > 0
        ? granularity
        : 1.0;
    final step = max(validGranularity, length / _maxSteps);

    // Sample the path at regular intervals
    final points = <Offset>[];
    for (double distance = 0; distance < length; distance += step) {
      final tangent = getTangentForOffset(distance);
      if (tangent != null) {
        points.add(tangent.position);
      }
    }

    // Add the endpoint
    final endTangent = getTangentForOffset(length);
    if (endTangent != null) {
      points.add(endTangent.position);
    }

    // Remove duplicate last point if any
    points.removeDuplicateLast();

    // Simplify using RDP algorithm.
    return _simplifyPolyline(points, tolerance ?? step / 2);
  }

  /// Simplify a polyline using the RDP algorithm.
  ///
  /// Recursively removes points that are within [tolerance] distance
  /// from the line segment connecting their neighbors.
  /// This preserves the overall shape while reducing vertex count.
  static OffsetList _simplifyPolyline(
    OffsetList points,
    double tolerance,
  ) {
    if (points.length <= 2) {
      return points;
    }

    // Find the point with maximum perpendicular distance from the line
    // formed by the first and last points
    var maxDistIndex = 0;
    var maxDist = 0.0;

    final start = points.first;
    final end = points.last;

    for (var i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], start, end);
      if (dist > maxDist) {
        maxDist = dist;
        maxDistIndex = i;
      }
    }

    // If max distance exceeds tolerance, recursively simplify both segments
    if (maxDist > tolerance) {
      final left = _simplifyPolyline(
        points.sublist(0, maxDistIndex + 1),
        tolerance,
      );
      final right = _simplifyPolyline(
        points.sublist(maxDistIndex),
        tolerance,
      );
      // Combine, removing duplicate point at the split
      return [...left.sublist(0, left.length - 1), ...right];
    }

    // Remove all intermediate points; keep only endpoints
    return [start, end];
  }

  /// Calculate the perpendicular distance from a point to a line segment.
  ///
  /// Uses the standard formula: |ax + by + c| / sqrt(a² + b²)
  /// where the line is defined by two points.
  static double _perpendicularDistance(
    Offset point,
    Offset lineStart,
    Offset lineEnd,
  ) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    // If the line segment has zero length, return distance to that point
    if (dx == 0 && dy == 0) {
      return (point - lineStart).distance;
    }

    // Perpendicular distance formula
    final numerator =
        (dy * point.dx -
                dx * point.dy +
                lineEnd.dx * lineStart.dy -
                lineEnd.dy * lineStart.dx)
            .abs();
    final denominator = sqrt(dx * dx + dy * dy);

    return numerator / denominator;
  }
}

extension Contours on PathMetrics {
  /// Return all the [PathMetric]s from a [Path]'s pre-computed metrics.
  PathMetricList get contours {
    return toList(growable: false);
  }

  /// Return the length of all contours in a [Path]'s pre-computed metrics.
  double get contoursLength {
    return contours.contoursLength;
  }
}

extension ContoursLength on PathMetricList {
  /// Compute the cumulative length of a [List] of [PathMetric] objects,
  /// provided by the [PathContours] extension.
  double get contoursLength {
    return fold(0.0, (sum, metric) => sum + metric.length);
  }
}
