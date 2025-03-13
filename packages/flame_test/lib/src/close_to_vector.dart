import 'package:flame_test/src/is_close_to_vector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Returns a matcher which checks if the argument is a vector within distance
/// [epsilon] of [vector]. For example:
///
/// ```dart
/// expect(scale, closeToVector(Vector2(2, -2)));
/// expect(position, closeToVector(expectedPosition, 1e-10));
/// ```
Matcher closeToVector(Vector2 vector, [double epsilon = 1e-15]) {
  return _IsCloseToVector2(vector, epsilon);
}

class _IsCloseToVector2 extends IsCloseToVector<Vector2> {
  const _IsCloseToVector2(super.value, super.epsilon);

  @override
  double dist(Vector2 a, Vector2 b) => (a - b).length;

  @override
  List<double> storage(Vector2 value) => value.storage;
}
