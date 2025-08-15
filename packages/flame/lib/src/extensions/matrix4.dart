import 'package:vector_math/vector_math.dart';

export 'package:vector_math/vector_math.dart' hide Colors;

extension Matrix4Extension on Matrix4 {
  /// A first row and first column value.
  double get m11 => storage[0];

  /// A first row and second column value.
  double get m12 => storage[1];

  /// A first row and third column value.
  double get m13 => storage[2];

  /// A first row and fourth column value.
  double get m14 => storage[3];

  /// A second row and first column value.
  double get m21 => storage[4];

  /// A second row and second column value.
  double get m22 => storage[5];

  /// A second row and third column value.
  double get m23 => storage[6];

  /// A second row and fourth column value.
  double get m24 => storage[7];

  /// A third row and first column value.
  double get m31 => storage[8];

  /// A third row and second column value.
  double get m32 => storage[9];

  /// A third row and third column value.
  double get m33 => storage[10];

  /// A third row and fourth column value.
  double get m34 => storage[11];

  /// A fourth row and first column value.
  double get m41 => storage[12];

  /// A fourth row and second column value.
  double get m42 => storage[13];

  /// A fourth row and third column value.
  double get m43 => storage[14];

  /// A fourth row and fourth column value.
  double get m44 => storage[15];

  /// Translate this matrix by a [Vector2].
  @Deprecated(
    'Use translateByDouble or translateByVector2 instead. '
    'This will be removed in a Flame 1.32.0.',
  )
  void translate2(Vector2 vector) {
    return translateByDouble(vector.x, vector.y, 0.0, 1.0);
  }

  /// Transform [position] of type [Vector2] using the transformation defined by
  /// this.
  Vector2 transform2(Vector2 position) {
    return Vector2(
      (position.x * m11) + (position.y * m21) + m41,
      (position.x * m12) + (position.y * m22) + m42,
    );
  }

  /// Transform a copy of [position] of type [Vector2] using the transformation
  /// defined by this. If a [out] parameter is supplied, the copy is stored in
  /// [out].
  Vector2 transformed2(Vector2 position, [Vector2? out]) {
    if (out == null) {
      // ignore: parameter_assignments
      out = Vector2.copy(position);
    } else {
      out.setFrom(position);
    }
    return transform2(out);
  }

  // TODO(spydon): Remove once min version is 3.35.0
  void translateByDouble(double tx, double ty, double tz, double tw) {
    final t1 =
        storage[0] * tx + storage[4] * ty + storage[8] * tz + storage[12] * tw;
    storage[12] = t1;

    final t2 =
        storage[1] * tx + storage[5] * ty + storage[9] * tz + storage[13] * tw;
    storage[13] = t2;

    final t3 =
        storage[2] * tx + storage[6] * ty + storage[10] * tz + storage[14] * tw;
    storage[14] = t3;

    final t4 =
        storage[3] * tx + storage[7] * ty + storage[11] * tz + storage[15] * tw;
    storage[15] = t4;
  }

  // TODO(spydon): Remove once min version is 3.35.0
  void scaleByDouble(double sx, double sy, double sz, double sw) {
    storage[0] *= sx;
    storage[1] *= sx;
    storage[2] *= sx;
    storage[3] *= sx;
    storage[4] *= sy;
    storage[5] *= sy;
    storage[6] *= sy;
    storage[7] *= sy;
    storage[8] *= sz;
    storage[9] *= sz;
    storage[10] *= sz;
    storage[11] *= sz;
    storage[12] *= sw;
    storage[13] *= sw;
    storage[14] *= sw;
    storage[15] *= sw;
  }

  // TODO(spydon): Remove once min version is 3.35.0
  void scaleByVector3(Vector3 vector) {
    scaleByDouble(
      vector.x,
      vector.y,
      vector.z,
      1.0,
    );
  }
}
