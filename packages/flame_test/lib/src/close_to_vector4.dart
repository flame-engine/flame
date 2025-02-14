import 'package:flame_test/src/is_close_to_vector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Returns a matcher which checks if the argument is a 4d vector within
/// distance [epsilon] of [vector]. For example:
///
/// ```dart
/// expect(matrix4.row1, closeToVector4(Vector4(1, 0, 0, 1)));
/// expect(matrix4.row2, closeToVector4(Vector4(0, 1, 0, -1), 1e-10));
/// ```
Matcher closeToVector4(Vector4 vector, [double epsilon = 1e-15]) {
  return _IsCloseToVector4(vector, epsilon);
}

class _IsCloseToVector4 extends IsCloseToVector<Vector4> {
  const _IsCloseToVector4(super.value, super.epsilon);

  @override
  double dist(Vector4 a, Vector4 b) => (a - b).length;

  @override
  List<double> storage(Vector4 value) => value.storage;
}
