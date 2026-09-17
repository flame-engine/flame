import 'dart:math' show max, min;
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
  /// The contour is sampled at regular intervals of about the [granularity],
  /// so that higher values produce fewer samples, which has to be a positive
  /// number. A closed contour is not sampled where it ends, since that is
  /// where it starts.
  ///
  /// The samples that are not needed to stay within [tolerance] of the sampled
  /// contour are removed. It defaults to half of the [granularity], and a
  /// [tolerance] of zero keeps every sample.
  OffsetList walkContour([double granularity = 1.0, double? tolerance]) {
    assert(
      granularity.isFinite && granularity > 0,
      'The granularity has to be a positive number: $granularity',
    );
    assert(
      tolerance == null || (tolerance.isFinite && tolerance >= 0),
      'The tolerance can not be negative: $tolerance',
    );
    if (!(length > 0)) {
      return [];
    }
    final validGranularity = granularity.isFinite && granularity > 0
        ? granularity
        : 1.0;
    final step = max(validGranularity, length / _maxSteps);
    final steps = (length / step).ceil();
    final points = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final tangent = getTangentForOffset(length * i / steps);
      if (tangent != null) {
        points.add(tangent.position);
      }
    }
    final closed =
        points.length > 1 && (isClosed || points.first == points.last);
    if (closed) {
      points.removeLast();
    }
    return _simplify(
      points,
      const [],
      closed: closed,
      tolerance: tolerance ?? step / 2,
    );
  }

  /// Remove the [points] that are within [tolerance] of the edge that replaces
  /// them, by extending each edge as far as that allows. This needs fewer
  /// vertices than splitting at the farthest point, which halves stretches
  /// that would have fit in one and a half edges.
  ///
  /// The [anchors] are the ascending indices of the points that have to be
  /// kept. Each stretch between two of them is simplified on its own,
  /// including the one that wraps around the end of a [closed] contour.
  static OffsetList _simplify(
    OffsetList points,
    List<int> anchors, {
    required bool closed,
    required double tolerance,
  }) {
    final count = points.length;
    if (count < 3 || tolerance <= 0) {
      return points;
    }
    final fixed = [...anchors];
    if (!closed) {
      if (fixed.isEmpty || fixed.first != 0) {
        fixed.insert(0, 0);
      }
      if (fixed.last != count - 1) {
        fixed.add(count - 1);
      }
    } else if (fixed.length < 2) {
      final origin = fixed.isEmpty ? 0 : fixed.first;
      final farthest = _farthestFrom(points, origin);
      fixed
        ..clear()
        ..add(min(origin, farthest));
      if (farthest != origin) {
        fixed.add(max(origin, farthest));
      }
    }

    final toleranceSquared = tolerance * tolerance;
    final keep = List.filled(count, false);
    for (var i = 0; i < fixed.length; i++) {
      keep[fixed[i]] = true;
      final isLast = i == fixed.length - 1;
      if (isLast && !closed) {
        break;
      }
      final to = isLast ? fixed.first + count : fixed[i + 1];
      var from = fixed[i];
      while (from < to) {
        from = _reach(points, from, to, toleranceSquared);
        keep[from % count] = true;
      }
    }
    return [
      for (var i = 0; i < count; i++)
        if (keep[i]) points[i],
    ];
  }

  /// The index of a point, as far after [from] as it could be found, up to
  /// which all the points are within the tolerance of the edge from [from] to
  /// it.
  ///
  /// The indices go past the end of [points] for the stretch that wraps around.
  static int _reach(
    OffsetList points,
    int from,
    int to,
    double toleranceSquared,
  ) {
    var reached = from + 1;
    var failed = -1;
    for (var stride = 2; reached < to; stride *= 2) {
      final candidate = min(from + stride, to);
      if (!_fits(points, from, candidate, toleranceSquared)) {
        failed = candidate;
        break;
      }
      reached = candidate;
    }
    while (failed - reached > 1) {
      final middle = (reached + failed) >> 1;
      if (_fits(points, from, middle, toleranceSquared)) {
        reached = middle;
      } else {
        failed = middle;
      }
    }
    return reached;
  }

  static bool _fits(
    OffsetList points,
    int from,
    int to,
    double toleranceSquared,
  ) {
    final count = points.length;
    final start = points[from % count];
    final end = points[to % count];
    for (var i = from + 1; i < to; i++) {
      final distance = _distanceToSegmentSquared(points[i % count], start, end);
      if (distance > toleranceSquared) {
        return false;
      }
    }
    return true;
  }

  static int _farthestFrom(OffsetList points, int origin) {
    var farthest = origin;
    var farthestDistance = 0.0;
    for (var i = 0; i < points.length; i++) {
      final distance = (points[i] - points[origin]).distanceSquared;
      if (distance > farthestDistance) {
        farthestDistance = distance;
        farthest = i;
      }
    }
    return farthest;
  }

  static double _distanceToSegmentSquared(
    Offset point,
    Offset from,
    Offset to,
  ) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final px = point.dx - from.dx;
    final py = point.dy - from.dy;
    final lengthSquared = dx * dx + dy * dy;
    final along = px * dx + py * dy;
    if (along <= 0) {
      return px * px + py * py;
    }
    if (along >= lengthSquared) {
      final ex = px - dx;
      final ey = py - dy;
      return ex * ex + ey * ey;
    }
    final across = px * dy - py * dx;
    return across * across / lengthSquared;
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
