import 'dart:math' show max, min, sqrt;
import 'dart:typed_data' show Float32List;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/src/cache/matrix_pool.dart' show pathTransform;

export 'dart:ui' show Path;

extension PathExtension on Path {
  Path transform32(Float32List matrix4) {
    return pathTransform(this, matrix4);
  }

  /// Returns a new [Path] with the given [size]. If [keepRatio] is true the
  /// aspect ratio is kept, so that the path fits within the [size].
  ///
  /// The path is scaled about the origin, like a canvas is, so a path that is
  /// [centered] stays centered and a path that was moved [toOrigin] stays
  /// there, while any other path moves along with its distance to the origin.
  ///
  /// A path without a width or a height is not scaled in that direction, since
  /// no scale can give it one.
  Path resizeTo(Size size, {bool keepRatio = false}) {
    assert(
      size.width > 0 && size.height > 0,
      'Resizing with invalid size: $size',
    );
    final box = getBounds();
    final hasWidth = box.width > 0;
    final hasHeight = box.height > 0;
    var scaleX = hasWidth ? size.width / box.width : 1.0;
    var scaleY = hasHeight ? size.height / box.height : 1.0;
    if (keepRatio) {
      final uniformScale = hasWidth && hasHeight
          ? min(scaleX, scaleY)
          : (hasWidth ? scaleX : scaleY);
      scaleX = uniformScale;
      scaleY = uniformScale;
    }
    final matrix = Float32List(16)
      ..[0] = scaleX
      ..[5] = scaleY
      ..[10] = 1
      ..[15] = 1;
    return transform32(matrix);
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
    final center = getBounds().center;
    if (center != .zero) {
      return shift(-center);
    }
    return this;
  }

  /// Return a list of [PathMetric] objects, corresponding to the contours
  /// in this path.
  List<PathMetric> get contours {
    return computeMetrics().toList(growable: false);
  }

  /// Walk the contours of a [Path] and return them as a list of [Offset] lists.
  /// Each entry in the list corresponds to a given sub-contour.
  ///
  /// See [PathMetricExtension.walkContour] for the [granularity] and the
  /// [tolerance] parameters.
  List<List<Offset>> walkContours([
    double granularity = 1.0,
    double? tolerance,
  ]) {
    return [
      for (final metric in computeMetrics())
        metric.walkContour(granularity, tolerance),
    ];
  }

  /// Walk only the contour at [index], without sampling the other contours of
  /// the path.
  ///
  /// See [PathMetricExtension.walkContour] for the [granularity] and the
  /// [tolerance] parameters.
  List<Offset> walkContourAt(
    int index, [
    double granularity = 1.0,
    double? tolerance,
  ]) {
    var current = 0;
    for (final metric in computeMetrics()) {
      if (current == index) {
        return metric.walkContour(granularity, tolerance);
      }
      current++;
    }
    throw RangeError.index(index, this, 'index', null, current);
  }
}

extension PathMetricExtension on PathMetric {
  /// The upper bound for the amount of sampling steps in a single contour.
  static const _maxSteps = 1 << 20;

  /// Walk a single contour of a [Path] and return it as an [Offset] list.
  ///
  /// The [granularity] is the sampling step along the contour: higher values
  /// produce fewer samples. It only limits how finely curves are followed,
  /// since straight stretches are skipped over and the corners between them
  /// are located exactly.
  ///
  /// The samples that are not needed to stay within [tolerance] of the sampled
  /// contour are removed, while the corners and the points where the contour
  /// reaches its bounds are always kept, so that the result has the size of
  /// the contour. The [tolerance] defaults to half of the [granularity], and
  /// the samples themselves are taken so that the contour stays within a sixth
  /// of it. A [tolerance] of zero keeps every sample.
  List<Offset> walkContour([double granularity = 1.0, double? tolerance]) {
    assert(
      granularity.isFinite && granularity > 0,
      'The granularity has to be a positive number: $granularity',
    );
    assert(
      tolerance == null || (tolerance.isFinite && tolerance >= 0),
      'The tolerance can not be negative: $tolerance',
    );
    if (length <= 0) {
      return [];
    }
    final validGranularity = granularity.isFinite && granularity > 0
        ? granularity
        : 1.0;
    final step = max(validGranularity, length / _maxSteps);
    final maxDeviation = tolerance ?? step / 2;
    final sampler = _ContourSampler(this, step, maxDeviation / 6)..sample();
    return _simplify(
      sampler.points,
      sampler.anchors,
      closed: sampler.isClosed,
      tolerance: maxDeviation,
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
  static List<Offset> _simplify(
    List<Offset> points,
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
    List<Offset> points,
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
    List<Offset> points,
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

  static int _farthestFrom(List<Offset> points, int origin) {
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

/// Samples a contour so that the polyline through [points] stays within
/// [_maxDeviation] of it, using as few tangent lookups as possible.
///
/// The stride to the next sample is predicted from how much the contour bent
/// over the previous one, so that straight stretches are crossed in a few
/// lookups while tight curves are followed below the step. A sample that turns
/// out to be too far ahead is kept in [_ahead] until the walk reaches it. The
/// indices of the corners and of the points where the contour reaches its
/// bounds are collected in [anchors].
class _ContourSampler {
  _ContourSampler(this._metric, this._step, this._maxDeviation);

  static const _maxStepsPerStride = 32;
  static const _subdivisionsPerStep = 4;

  final PathMetric _metric;
  final double _step;
  final double _maxDeviation;

  final List<Offset> points = [];
  final List<int> anchors = [];
  bool isClosed = false;

  /// A feature that stays unnoticed by the length check of a curved stretch is
  /// at most a twenty-fifth of the stretch deep, which has to be within the
  /// tolerance, that is six times [_maxDeviation].
  late final double _maxCurveStride = 150 * _maxDeviation;

  final List<int> _turns = [];
  bool _isAfterLine = false;
  final List<Tangent> _ahead = [];
  final List<double> _aheadOffsets = [];
  Tangent? _spare;
  double _spareOffset = 0;

  Tangent? _lookup(double offset) => _metric.getTangentForOffset(offset);

  void sample() {
    final length = _metric.length;
    final first = _lookup(0);
    if (first == null) {
      return;
    }
    final maxStride = _step * _maxStepsPerStride;
    final minStride = _maxDeviation > 0 ? _step / _subdivisionsPerStep : _step;

    points.add(first.position);
    var from = first;
    var fromOffset = 0.0;
    var stride = _step;
    // Every round either moves on or shortens the stride by a fifth at least,
    // the limit only keeps an unforeseen case from never returning.
    final maxRounds = 64 * (length / minStride).ceil() + 64;
    for (var round = 0; fromOffset < length && round < maxRounds; round++) {
      _spare = null;
      while (_ahead.isNotEmpty && _aheadOffsets.last <= fromOffset) {
        _ahead.removeLast();
        _aheadOffsets.removeLast();
      }
      final Tangent? to;
      final double toOffset;
      if (_ahead.isNotEmpty &&
          _aheadOffsets.last <= fromOffset + stride * 1.2) {
        to = _ahead.removeLast();
        toOffset = _aheadOffsets.removeLast();
      } else {
        final isLast = length - fromOffset <= stride * 1.2;
        toOffset = isLast ? length : fromOffset + stride;
        to = _lookup(toOffset);
      }
      if (to == null) {
        break;
      }
      final arc = toOffset - fromOffset;
      final bend = _bend(from, to, arc);
      if (bend <= 1) {
        _addExtremes(fromOffset, from, toOffset, to);
        _add(to.position);
        _isAfterLine = bend == 0;
        stride = bend < 1e-3 ? maxStride : arc * 0.9 / sqrt(bend);
        if (stride > maxStride) {
          stride = maxStride;
        } else if (stride < minStride) {
          stride = minStride;
        }
      } else if (_addCorner(fromOffset, from, to, arc)) {
        stride = max(arc, minStride);
        _isAfterLine = true;
      } else if (arc <= minStride * 1.2) {
        _isAfterLine = false;
        _add(to.position);
        stride = minStride;
      } else {
        _ahead.add(to);
        _aheadOffsets.add(toOffset);
        final spare = _spare;
        if (spare != null) {
          _ahead.add(spare);
          _aheadOffsets.add(_spareOffset);
          _spare = null;
        }
        var shrink = bend.isFinite ? 0.9 / sqrt(bend) : 0.5;
        if (shrink > 0.8) {
          shrink = 0.8;
        } else if (shrink < 0.25) {
          shrink = 0.25;
        }
        stride = max(arc * shrink, minStride);
        continue;
      }
      from = to;
      fromOffset = toOffset;
    }
    if (fromOffset < length) {
      final last = _lookup(length);
      if (last != null) {
        _add(last.position);
        from = last;
      }
    }
    _close(first, from);
  }

  /// Joins the end of a closed contour with its start, which are the same
  /// point with possibly different tangents.
  ///
  /// The turns only become anchors when they are on the bounds of the contour,
  /// since the other ones are as good as any other sample.
  void _close(Tangent first, Tangent last) {
    isClosed =
        points.length > 1 && (_metric.isClosed || points.first == points.last);
    var seam = -1;
    if (isClosed) {
      points.removeLast();
      seam = points.length;
      final from = last.vector;
      final to = first.vector;
      if (from.dx * to.dx + from.dy * to.dy < 0.9999) {
        anchors.add(0);
      }
      if (_changesDirection(from.dx, to.dx) ||
          _changesDirection(from.dy, to.dy)) {
        _turns.add(0);
      }
    }

    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;
    for (final point in points) {
      left = min(left, point.dx);
      top = min(top, point.dy);
      right = max(right, point.dx);
      bottom = max(bottom, point.dy);
    }
    final fixed = <int>{
      for (final index in anchors)
        if (index == seam) 0 else index,
    };
    final count = points.length;
    final turnSides = <int, int>{};
    for (final turn in _turns) {
      final index = turn == seam ? 0 : turn;
      final point = points[index];
      final sides =
          (point.dx - left <= _maxDeviation ? 1 : 0) |
          (right - point.dx <= _maxDeviation ? 2 : 0) |
          (point.dy - top <= _maxDeviation ? 4 : 0) |
          (bottom - point.dy <= _maxDeviation ? 8 : 0);
      // A turn adds nothing when a neighboring sample is on the same sides of
      // the bounds already.
      final neighborSides =
          (turnSides[(index + 1) % count] ?? 0) |
          (turnSides[(index - 1 + count) % count] ?? 0);
      if (sides & ~neighborSides == 0) {
        continue;
      }
      turnSides[index] = sides;
      fixed.add(index);
    }
    anchors
      ..clear()
      ..addAll(fixed)
      ..sort();
  }

  void _add(Offset point, {bool isAnchor = false, bool isTurn = false}) {
    if (point != points.last) {
      points.add(point);
    }
    if (isAnchor) {
      _anchorLast();
    }
    if (isTurn) {
      _turnLast();
    }
  }

  void _anchorLast() {
    final index = points.length - 1;
    if (anchors.isEmpty || anchors.last != index) {
      anchors.add(index);
    }
  }

  void _turnLast() {
    final index = points.length - 1;
    if (_turns.isEmpty || _turns.last != index) {
      _turns.add(index);
    }
  }

  /// How far the contour between the two samples bends away from the chord
  /// between them, as a share of [_maxDeviation]. The stretch is flat enough
  /// when this is at most one.
  ///
  /// When both tangents are aligned with the chord the stretch is a line,
  /// unless something is hidden between the samples. A stretch of length `arc`
  /// between two points can not leave the ellipse that has them as its foci,
  /// whose semi-minor axis is `sqrt(arc² - chord²) / 2`, and lengths are exact
  /// along lines, so that settles it.
  ///
  /// Lengths along curves are off by up to a third over short stretches, so
  /// there the bend comes from the tangents: a curve with end tangents at the
  /// angles `a` and `b` to its chord deviates by about `chord * (a + b) / 8`
  /// from it. Its length only has to be plausible, which together with
  /// [_maxCurveStride] limits what could hide between the samples.
  double _bend(Tangent from, Tangent to, double arc) {
    final dx = to.position.dx - from.position.dx;
    final dy = to.position.dy - from.position.dy;
    final fromVector = from.vector;
    final toVector = to.vector;
    if (dx * fromVector.dx + dy * fromVector.dy <= 0 ||
        dx * toVector.dx + dy * toVector.dy <= 0) {
      return double.infinity;
    }
    final sway =
        (dx * fromVector.dy - dy * fromVector.dx).abs() +
        (dx * toVector.dy - dy * toVector.dx).abs();
    final chordSquared = dx * dx + dy * dy;
    final arcSquared = arc * arc;
    if (sway <= 1e-4 * arc) {
      final limit = 4 * _maxDeviation * _maxDeviation;
      return arcSquared - chordSquared > limit ? double.infinity : 0;
    }
    if (arc > _maxCurveStride ||
        (arc > _step && chordSquared < 0.85 * arcSquared)) {
      return double.infinity;
    }
    return sway / (8 * _maxDeviation);
  }

  /// Adds the corner between the two samples together with the `to` sample, if
  /// the contour between them consists of two straight lines.
  ///
  /// That is the case when the legs from the samples to the point where their
  /// tangent lines meet are together as long as the contour between them.
  bool _addCorner(double fromOffset, Tangent from, Tangent to, double arc) {
    final fromVector = from.vector;
    final toVector = to.vector;
    final cross = fromVector.dx * toVector.dy - fromVector.dy * toVector.dx;
    if (cross.abs() < 1e-6) {
      return false;
    }
    final dx = to.position.dx - from.position.dx;
    final dy = to.position.dy - from.position.dy;
    final fromLeg = (dx * toVector.dy - dy * toVector.dx) / cross;
    final toLeg = (fromVector.dx * dy - fromVector.dy * dx) / cross;
    final slack = max(2 * _maxDeviation * _maxDeviation / arc, arc * 1e-6);
    if (fromLeg < -slack ||
        toLeg < -slack ||
        (fromLeg + toLeg - arc).abs() > slack) {
      return false;
    }
    final corner = from.position + fromVector * fromLeg;
    final merge = max(_maxDeviation / 2, arc * 1e-6);
    if (fromLeg > merge && toLeg > merge) {
      // A staircase is as long as a single corner, so the contour has to pass
      // through the corner as well.
      final sample = _lookup(fromOffset + fromLeg);
      if (sample == null) {
        return false;
      }
      if ((sample.position - corner).distance > slack) {
        if (toLeg > arc / 8 && fromLeg > arc / 8) {
          _spare = sample;
          _spareOffset = fromOffset + fromLeg;
        }
        return false;
      }
    }
    if (fromLeg <= merge) {
      points.last = corner;
      _anchorLast();
      _add(to.position);
    } else if (toLeg <= merge) {
      _add(corner, isAnchor: true);
    } else {
      _add(corner, isAnchor: true);
      _add(to.position);
    }
    return true;
  }

  /// Anchors the points where the contour turns around horizontally or
  /// vertically between the two samples, since those define its bounds.
  void _addExtremes(
    double fromOffset,
    Tangent from,
    double toOffset,
    Tangent to,
  ) {
    final fromVector = from.vector;
    final toVector = to.vector;
    final turnsX = _changesDirection(fromVector.dx, toVector.dx);
    final turnsY = _changesDirection(fromVector.dy, toVector.dy);
    if (!turnsX && !turnsY) {
      return;
    }
    final arc = toOffset - fromOffset;
    final shareX = turnsX ? _turnShare(fromVector.dx, toVector.dx) : 2.0;
    final shareY = turnsY ? _turnShare(fromVector.dy, toVector.dy) : 2.0;
    if (shareX == 0 || shareY == 0) {
      // Without a line before it, the sample is where a curve turns around.
      final junction = _isAfterLine
          ? _junction(from, to, alongFrom: true)
          : null;
      if (junction == null) {
        _turnLast();
      } else {
        _add(junction, isTurn: true);
      }
    }
    for (final share in [min(shareX, shareY), max(shareX, shareY)]) {
      if (share > 0 && share < 1) {
        final extreme = _lookup(fromOffset + arc * share);
        if (extreme != null) {
          _add(extreme.position, isTurn: true);
        }
      }
    }
    if (shareX == 1 || shareY == 1) {
      _add(
        _junction(from, to, alongFrom: false) ?? to.position,
        isTurn: true,
      );
    }
  }

  /// The point where the tangent lines of the two samples of a flat stretch
  /// meet, if it lies between them.
  ///
  /// When one of the samples is on a line that is parallel to an axis and the
  /// other one is on a curve that leaves it, this point is on that line and
  /// next to the point where the curve starts.
  Offset? _junction(Tangent from, Tangent to, {required bool alongFrom}) {
    final fromVector = from.vector;
    final toVector = to.vector;
    final cross = fromVector.dx * toVector.dy - fromVector.dy * toVector.dx;
    if (cross.abs() < 1e-6) {
      return null;
    }
    final dx = to.position.dx - from.position.dx;
    final dy = to.position.dy - from.position.dy;
    final fromLeg = (dx * toVector.dy - dy * toVector.dx) / cross;
    final toLeg = (fromVector.dx * dy - fromVector.dy * dx) / cross;
    if (fromLeg <= 0 || toLeg <= 0) {
      return null;
    }
    // Measured along the axis-parallel line, so that the point is exactly on
    // it.
    return alongFrom
        ? from.position + fromVector * fromLeg
        : to.position - toVector * toLeg;
  }

  static bool _changesDirection(double from, double to) {
    return from.sign != to.sign;
  }

  /// How far between two samples a tangent component passes through zero.
  static double _turnShare(double from, double to) {
    return from.abs() / (from.abs() + to.abs());
  }
}

extension PathMetricListExtension on List<PathMetric> {
  /// Compute the cumulative length of a [List] of [PathMetric] objects, like
  /// the [PathExtension.contours] of a [Path].
  double get contoursLength {
    return fold(0.0, (sum, metric) => sum + metric.length);
  }
}
