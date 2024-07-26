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
  return _IsCloseTo(vector, epsilon);
}

class _IsCloseTo extends Matcher {
  const _IsCloseTo(this._value, this._epsilon);

  final Vector3 _value;
  final double _epsilon;

  @override
  bool matches(dynamic item, Map matchState) {
    return (item is Vector3) && (item - _value).length <= _epsilon;
  }

  @override
  Description describe(Description description) {
    final coords = '${_value.x}, ${_value.y}, ${_value.z}';
    return description.add('a Vector3 object within $_epsilon of ($coords)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Vector3) {
      return mismatchDescription.add('is not an instance of Vector3');
    }
    final distance = (item - _value).length;
    return mismatchDescription.add('is at distance $distance');
  }
}
