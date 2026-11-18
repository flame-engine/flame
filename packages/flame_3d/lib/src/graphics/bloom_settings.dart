/// {@template bloom_settings}
/// Soft-knee GPU bloom post-processing for a `World3D` or `Scene3DComponent`.
///
/// Bright pixels above [threshold] (smoothed over [softKnee]) are extracted at
/// reduced resolution, blurred across [passes] dual-Kawase iterations scaled
/// by [radius], and added back onto the rendered image at [intensity] while
/// preserving target alpha for transparent `Scene3DComponent` layers.
/// {@endtemplate}
class BloomSettings({
  /// Brightness threshold above which fragments contribute to bloom (`>= 0`).
  var double threshold = 0.8,

  /// Soft transition width around [threshold] in `[0, 1]`.
  var double softKnee = 0.5,

  /// Additive bloom strength (`0` disables bloom).
  var double intensity = 0.6,

  /// Filter spread multiplier in texels (`> 0`).
  var double radius = 1.0,

  /// Number of blur passes (`1` to `4`).
  int passes = 2,
}) {
  /// {@macro bloom_settings}
  this {
    this.passes = passes;
  }

  /// Number of blur iterations (`1` to `4`).
  int get passes => _passes;
  int _passes = 2;
  set passes(int value) {
    if (value < 1 || value > 4) {
      throw ArgumentError.value(value, 'passes', 'Must be between 1 and 4');
    }
    _passes = value;
  }
}
