import 'dart:typed_data';
import 'dart:ui';

/// A color gradient over a particle's lifetime.
///
/// The gradient is baked into a lookup table when constructed, so evaluating
/// it per particle per frame is a single array read.
class ColorRamp {
  /// Creates a ramp that interpolates through [colors] over the particle's
  /// lifetime.
  ///
  /// [stops] optionally positions each color on the 0...1 life progress
  /// axis; when omitted the colors are spaced evenly.
  ColorRamp(List<Color> colors, {List<double>? stops})
    : assert(colors.isNotEmpty, 'colors must not be empty'),
      assert(
        stops == null || stops.length == colors.length,
        'stops must have the same length as colors',
      ) {
    if (colors.length == 1) {
      _lut.fillRange(0, _resolution, colors.first.toARGB32());
      return;
    }
    final positions =
        stops ?? List.generate(colors.length, (i) => i / (colors.length - 1));
    var segment = 0;
    for (var i = 0; i < _resolution; i++) {
      final t = i / (_resolution - 1);
      while (segment < colors.length - 2 && t > positions[segment + 1]) {
        segment++;
      }
      final start = positions[segment];
      final end = positions[segment + 1];
      final local = end > start ? ((t - start) / (end - start)) : 1.0;
      final color = Color.lerp(
        colors[segment],
        colors[segment + 1],
        local.clamp(0.0, 1.0),
      )!;
      _lut[i] = color.toARGB32();
    }
  }

  /// A ramp that keeps the same [color] over the whole lifetime.
  ColorRamp.solid(Color color) : this([color]);

  static const int _resolution = 256;

  final Int32List _lut = Int32List(_resolution);

  /// The 32-bit ARGB value at life progress [t], which is clamped to 0...1.
  ///
  /// The value is read from an [Int32List], so it may be negative when
  /// interpreted as a signed integer; mask with `0xffffffff` before passing
  /// it to a [Color] constructor.
  int valueAt(double t) {
    return _lut[(t.clamp(0.0, 1.0) * (_resolution - 1)).toInt()];
  }

  /// The [Color] at life progress [t], which is clamped to 0...1.
  Color colorAt(double t) => Color(valueAt(t) & 0xffffffff);
}
