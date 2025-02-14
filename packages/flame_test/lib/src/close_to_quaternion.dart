import 'package:flame_test/src/is_close_to_vector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Returns a matcher which checks if the argument is a Quaternion within
/// distance [epsilon] of [quaternion]. For example:
///
/// ```dart
/// expect(
///   rotation,
///   closeToQuaternion(Quaternion.axisAngle(Vector3(1, 0, 0), pi / 2)),
/// );
/// ```
Matcher closeToQuaternion(Quaternion quaternion, [double epsilon = 1e-15]) {
  return _IsCloseToQuaternion(quaternion, epsilon);
}

class _IsCloseToQuaternion extends IsCloseToVector<Quaternion> {
  const _IsCloseToQuaternion(super.value, super.epsilon);

  @override
  double dist(Quaternion a, Quaternion b) => (a - b).length;

  @override
  List<double> storage(Quaternion value) => value.storage;
}
