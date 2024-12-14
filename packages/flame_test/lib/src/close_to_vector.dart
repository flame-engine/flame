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
  return _IsCloseTo(vector, epsilon);
}

class _IsCloseTo extends Matcher {
  const _IsCloseTo(this._value, this._epsilon);

  final Vector2 _value;
  final double _epsilon;

  @override
  bool matches(dynamic item, Map matchState) {
    return (item is Vector2) && (item - _value).length <= _epsilon;
  }

  @override
  Description describe(Description description) => description
      .add('a Vector2 object within $_epsilon of (${_value.x}, ${_value.y})');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Vector2) {
      return mismatchDescription.add('is not an instance of Vector2');
    }
    final distance = (item - _value).length;
    return mismatchDescription.add('is at distance $distance');
  }
}
