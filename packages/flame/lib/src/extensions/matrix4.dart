import 'package:vector_math/vector_math_64.dart';

export 'package:vector_math/vector_math_64.dart' hide Colors;

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
  void translate2(Vector2 vector) {
    return translate(vector.x, vector.y);
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

  /// Create a scaled matrix.
  ///
  /// Scale by a [Vector3], [Vector4], or x,y,z
  static Matrix4 scale(dynamic x, [double? y, double? z]) {
    return Matrix4.identity()..scale(x, y, z);
  }
}
