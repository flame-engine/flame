import 'package:flame_test/src/is_close_to_vector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Returns a matcher which checks if the argument is a 3d vector within
/// distance [epsilon] of [vector]. For example:
///
/// ```dart
/// expect(scale, closeToVector3(Vector3(2, -2, 0)));
/// expect(position, closeToVector3(expectedPosition, 1e-10));
/// ```
Matcher closeToVector3(Vector3 vector, [double epsilon = 1e-15]) {
  return _IsCloseToVector3(vector, epsilon);
}

class _IsCloseToVector3 extends IsCloseToVector<Vector3> {
  const _IsCloseToVector3(super.value, super.epsilon);

  @override
  double dist(Vector3 a, Vector3 b) => (a - b).length;

  @override
  List<double> storage(Vector3 value) => value.storage;
}
