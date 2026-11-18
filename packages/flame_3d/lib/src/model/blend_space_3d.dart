import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/model/model_animation.dart';

/// A single animation clip positioned along a 1D parameter axis inside a
/// [BlendSpace1D] (for example `Idle` at `0.0`, `Walk` at `2.0`, `Run` at
/// `5.5`).
class BlendSample1D({
  required final ModelAnimation animation,
  required final double position,
  final double speed = 1.0,
});

/// Continuous 1D locomotion / pose blend space sorted by
/// [BlendSample1D.position].
///
/// When [syncNormalizedPhase] is `true`, playback advances a shared normalized
/// `[0..1)` gait cycle so footfalls remain phase-locked while blending between
/// clips of different durations (such as `Walk` and `Run`).
class BlendSpace1D({
  required List<BlendSample1D> samples,
  final bool syncNormalizedPhase = true,
}) {
  /// Samples ordered ascending by [BlendSample1D.position].
  final List<BlendSample1D> samples = _validateAndSort(samples);

  static List<BlendSample1D> _validateAndSort(List<BlendSample1D> raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(raw, 'samples', 'Must contain >= 1 sample');
    }
    final sorted = List<BlendSample1D>.of(raw)
      ..sort((a, b) => a.position.compareTo(b.position));
    return List<BlendSample1D>.unmodifiable(sorted);
  }

  /// Resolves the bracketing sample pair `(indexA, indexB)` and blend factor
  /// `t` in `[0, 1]` for parameter [value].
  ({int indexA, int indexB, double t}) resolveBracket(double value) {
    final len = samples.length;
    if (len == 1 || value <= samples.first.position) {
      return (indexA: 0, indexB: 0, t: 0.0);
    }
    if (value >= samples.last.position) {
      final last = len - 1;
      return (indexA: last, indexB: last, t: 0.0);
    }
    for (var i = 0; i < len - 1; i++) {
      final p0 = samples[i].position;
      final p1 = samples[i + 1].position;
      if (value <= p1) {
        final span = p1 - p0;
        final t = span > 1e-9 ? ((value - p0) / span).clamp(0.0, 1.0) : 0.0;
        return (indexA: i, indexB: i + 1, t: t);
      }
    }
    final last = len - 1;
    return (indexA: last, indexB: last, t: 0.0);
  }
}

/// A single animation clip positioned at a 2D parameter [point] inside a
/// [BlendSpace2D] (such as `(strafeX, forwardY)`).
class BlendSample2D({
  required final ModelAnimation animation,
  required Vector2 point,
  final double speed = 1.0,
}) {
  /// Parameter-space coordinates of this sample.
  final Vector2 point = point.clone();
}

/// Freeform 2D directional / Cartesian blend space computing smooth
/// gradient-band barycentric weights across up to 4 nearest [BlendSample2D]s
/// (`sum(w_i) == 1.0`) with zero per-frame heap allocations.
class BlendSpace2D({
  required List<BlendSample2D> samples,
  final bool syncNormalizedPhase = true,
}) {
  /// Samples registered in this 2D blend space.
  final List<BlendSample2D> samples = _validate(samples);

  late final Float64List _rawWeights = Float64List(samples.length);
  late final Float64List _distSq = Float64List(samples.length);

  static List<BlendSample2D> _validate(List<BlendSample2D> raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(raw, 'samples', 'Must contain >= 1 sample');
    }
    return List<BlendSample2D>.unmodifiable(raw);
  }

  /// Evaluates up to `4` active sample weights (`sum == 1.0`) for 2D parameter
  /// [input] into [outIndices] and [outWeights] (both must have length `>= 4`),
  /// returning the active sample count in `1..4`.
  int evaluateWeights(
    Vector2 input,
    Int32List outIndices,
    Float64List outWeights,
  ) {
    if (outIndices.length < 4 || outWeights.length < 4) {
      throw ArgumentError('outIndices and outWeights must have length >= 4');
    }
    final n = samples.length;
    if (n == 1) {
      outIndices[0] = 0;
      outWeights[0] = 1.0;
      return 1;
    }

    final ix = input.x;
    final iy = input.y;

    for (var i = 0; i < n; i++) {
      final pi = samples[i].point;
      final dx = ix - pi.x;
      final dy = iy - pi.y;
      final d2 = dx * dx + dy * dy;
      if (d2 <= 1e-12) {
        outIndices[0] = i;
        outWeights[0] = 1.0;
        return 1;
      }
      _distSq[i] = d2;
    }

    // Gradient-band interpolation:
    // h_i(p) = min_{j != i} clamp(1 - dot(p - p_i, p_j - p_i) / |p_j - p_i|^2).
    var totalRaw = 0.0;
    for (var i = 0; i < n; i++) {
      final pi = samples[i].point;
      final vpx = ix - pi.x;
      final vpy = iy - pi.y;
      var minBand = 1.0;
      for (var j = 0; j < n; j++) {
        if (i == j) {
          continue;
        }
        final pj = samples[j].point;
        final vx = pj.x - pi.x;
        final vy = pj.y - pi.y;
        final len2 = vx * vx + vy * vy;
        if (len2 <= 1e-12) {
          continue;
        }
        final proj = (vpx * vx + vpy * vy) / len2;
        final band = (1.0 - proj).clamp(0.0, 1.0);
        if (band < minBand) {
          minBand = band;
          if (minBand <= 0.0) {
            break;
          }
        }
      }
      _rawWeights[i] = minBand;
      totalRaw += minBand;
    }

    // Fallback to inverse-distance weighting if degenerate sample layout.
    if (totalRaw <= 1e-12) {
      for (var i = 0; i < n; i++) {
        final w = 1.0 / (_distSq[i] + 1e-6);
        _rawWeights[i] = w;
      }
    }

    // Select up to 4 highest-weight samples without allocating.
    var count = 0;
    for (var i = 0; i < n; i++) {
      final w = _rawWeights[i];
      if (w <= 1e-9) {
        continue;
      }
      if (count < 4) {
        var pos = count++;
        while (pos > 0 && outWeights[pos - 1] < w) {
          outWeights[pos] = outWeights[pos - 1];
          outIndices[pos] = outIndices[pos - 1];
          pos--;
        }
        outWeights[pos] = w;
        outIndices[pos] = i;
      } else if (w > outWeights[3]) {
        var pos = 3;
        while (pos > 0 && outWeights[pos - 1] < w) {
          outWeights[pos] = outWeights[pos - 1];
          outIndices[pos] = outIndices[pos - 1];
          pos--;
        }
        outWeights[pos] = w;
        outIndices[pos] = i;
      }
    }

    if (count == 0) {
      var nearest = 0;
      for (var i = 1; i < n; i++) {
        if (_distSq[i] < _distSq[nearest]) {
          nearest = i;
        }
      }
      outIndices[0] = nearest;
      outWeights[0] = 1.0;
      return 1;
    }

    var sum = 0.0;
    for (var k = 0; k < count; k++) {
      sum += outWeights[k];
    }
    final invSum = 1.0 / sum;
    for (var k = 0; k < count; k++) {
      outWeights[k] *= invSum;
    }
    return count;
  }
}
