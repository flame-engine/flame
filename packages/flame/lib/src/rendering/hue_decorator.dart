import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/src/rendering/decorator.dart';

/// Calculates the hue rotation matrix for a given angle in radians.
///
/// Uses the standard NTSC luminance weights (R: 0.213, G: 0.715, B: 0.072)
/// to produce a 4x5 color matrix suitable for [ColorFilter.matrix].
List<double> hueRotationMatrix(double angle) {
  final cosT = math.cos(angle);
  final sinT = math.sin(angle);

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

/// [HueDecorator] is a [Decorator] that shifts the hue of the component.
///
/// The [hue] value is in radians.
/// Standard range is from -pi to pi, or 0 to 2*pi.
///
/// **Performance Note**: This decorator uses `canvas.saveLayer()` which has
/// significant overhead compared to direct [Paint] manipulation (like
/// `HueEffect`). Prefer `HueEffect` for high-density rendering.
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
    _paint.colorFilter = ColorFilter.matrix(hueRotationMatrix(_hue));
  }
}
