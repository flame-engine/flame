import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';

/// [HueDecorator] is a [Decorator] that shifts the hue of the component.
///
/// The [hue] value is in radians.
/// Standard range is from -pi to pi, or 0 to 2*pi.
class HueDecorator extends Decorator {
  HueDecorator({double hue = 0.0}) : _hue = hue;

  final _paint = Paint();
  double _hue;
  bool _isDirty = true;

  /// The hue shift in radians.
  double get hue => _hue;
  set hue(double value) {
    if (_hue != value) {
      _hue = value;
      _isDirty = true;
    }
  }

  @override
  void apply(
    void Function(Canvas) draw,
    Canvas canvas,
  ) {
    if (_hue == 0.0) {
      draw(canvas);
      return;
    }

    if (_isDirty) {
      _updatePaint();
      _isDirty = false;
    }

    canvas.saveLayer(null, _paint);
    draw(canvas);
    canvas.restore();
  }

  void _updatePaint() {
    _paint.colorFilter = ColorFilter.matrix(hueMatrix(_hue));
  }

  /// Calculates the hue rotation matrix for a given angle in radians.
  static List<double> hueMatrix(double angle) {
    final cosT = math.cos(angle);
    final sinT = math.sin(angle);

    // Standard hue rotation matrix using NTSC luminance weights:
    // R: 0.213, G: 0.715, B: 0.072
    return <double>[
      0.213 + 0.787 * cosT - 0.213 * sinT,
      0.715 - 0.715 * cosT - 0.715 * sinT,
      0.072 - 0.072 * cosT + 0.928 * sinT,
      0,
      0,
      0.213 - 0.213 * cosT + 0.143 * sinT,
      0.715 + 0.285 * cosT + 0.140 * sinT,
      0.072 - 0.072 * cosT - 0.283 * sinT,
      0,
      0,
      0.213 - 0.213 * cosT - 0.787 * sinT,
      0.715 - 0.715 * cosT + 0.715 * sinT,
      0.072 + 0.928 * cosT + 0.072 * sinT,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}
