/// The zooms an editor canvas steps through when zooming in and out, `1`
/// being the actual size.
abstract final class ZoomLevels() {
  /// Creates a [ZoomLevels].
  this;

  /// The smallest zoom.
  static const min = 0.1;

  /// The largest zoom.
  static const max = 8.0;

  /// Every level, from [min] to [max].
  static const List<double> all = [
    min,
    0.25,
    0.5,
    0.75,
    1,
    1.5,
    2,
    3,
    4,
    6,
    max,
  ];

  static const _tolerance = 1e-6;

  /// The zoom after zooming in from [zoom], or `null` if it is [max]
  /// already. A zoom between two levels goes to the larger one.
  static double? next(double zoom) {
    for (final level in all) {
      if (level > zoom + _tolerance) {
        return level;
      }
    }
    return null;
  }

  /// The zoom after zooming out from [zoom], or `null` if it is [min]
  /// already. A zoom between two levels goes to the smaller one.
  static double? previous(double zoom) {
    for (final level in all.reversed) {
      if (level < zoom - _tolerance) {
        return level;
      }
    }
    return null;
  }
}
