import 'package:flame/components.dart';

class NullableVector2 {
  NullableVector2(this.x, this.y);

  double? x;
  double? y;

  factory NullableVector2.fromVector2(Vector2? vector2) {
    return NullableVector2(vector2?.x, vector2?.y);
  }

  factory NullableVector2.blank() {
    return NullableVector2(null, null);
  }

  /// Access the component of the vector at the index [i].
  double? operator [](int i) {
    if (i == 0) {
      return x;
    } else if (i == 1) {
      return y;
    } else {
      throw Exception('Unsupported index: $i');
    }
  }

  /// Set the component of the vector at the index [i].
  void operator []=(int i, double? v) {
    if (i == 0) {
      x = v;
    } else if (i == 1) {
      y = v;
    } else {
      throw Exception('Unsupported index: $i');
    }
  }

  /// Set the values by copying them from [other].
  void setFrom(NullableVector2? other) {
    x = other?.x;
    y = other?.y;
  }

  /// Because [NullableVector2]'s axis components are nullable, [fallback] is
  /// necessary to fill in the appropriate values in case [x] or [y] is null.
  Vector2 toVector(Vector2 fallback) {
    return Vector2(x ?? fallback.x, y ?? fallback.y);
  }

  /// Returns a printable string
  @override
  String toString() => '[$x,$y]';
}
