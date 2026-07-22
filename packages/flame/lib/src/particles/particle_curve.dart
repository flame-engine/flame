import 'dart:typed_data';

import 'package:flutter/animation.dart';

/// A scalar value that changes over a particle's lifetime.
///
/// The curve is baked into a small lookup table when constructed, so
/// evaluating it for thousands of particles per frame costs only an array
/// read and one interpolation, no matter how expensive the source function
/// is.
class ParticleCurve {
  /// Interpolates from [from] at spawn to [to] at death, optionally shaped
  /// by an animation [curve] (for example [Curves.easeOut]).
  ParticleCurve(double from, double to, {Curve curve = Curves.linear})
    : this.custom((t) => from + (to - from) * curve.transform(t));

  /// Keeps the same [value] over the whole lifetime.
  ParticleCurve.constant(double value) : this.custom((_) => value);

  /// Bakes an arbitrary function of the life progress `t`, where `t` goes
  /// from 0 at spawn to 1 at death.
  ParticleCurve.custom(double Function(double t) f)
    : _samples = Float32List(_resolution + 1) {
    for (var i = 0; i <= _resolution; i++) {
      _samples[i] = f(i / _resolution);
    }
  }

  static const int _resolution = 64;

  final Float32List _samples;

  /// Evaluates the curve at life progress [t], which is clamped to 0...1.
  double transform(double t) {
    final scaled = t.clamp(0.0, 1.0) * _resolution;
    final index = scaled.floor();
    if (index >= _resolution) {
      return _samples[_resolution];
    }
    final fraction = scaled - index;
    return _samples[index] * (1 - fraction) + _samples[index + 1] * fraction;
  }
}
