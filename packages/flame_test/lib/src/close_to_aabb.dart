import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart';

/// Returns a matcher which checks if the argument is an axis-aligned bounding
/// box sufficiently close (within distance [epsilon]) to [expected]. Example
/// of usage:
/// ```dart
/// expect(
///   component.aabb,
///   closeToAabb(Aabb2.minMax(Vector2.zero(), Vector2.all(1)), 1e-5),
/// );
/// ```
Matcher closeToAabb(Aabb2 expected, [double epsilon = 1e-15]) {
  return _IsCloseToAabb(expected, epsilon);
}

class _IsCloseToAabb extends Matcher {
  const _IsCloseToAabb(this._expected, this._epsilon);

  final Aabb2 _expected;
  final double _epsilon;

  @override
  bool matches(dynamic item, Map matchState) {
    return (item is Aabb2) &&
        (item.min - _expected.min).length <= _epsilon &&
        (item.max - _expected.max).length <= _epsilon;
  }

  @override
  Description describe(Description description) {
    return description.add(
      'an Aabb2 object within $_epsilon of Aabb2([${_expected.min.x}, '
      '${_expected.min.y}]..[${_expected.max.x}, ${_expected.max.y}])',
    );
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Aabb2) {
      return mismatchDescription.add('is not an instance of Aabb2');
    }
    final minDiff = (item.min - _expected.min).length;
    final maxDiff = (item.max - _expected.max).length;
    if (minDiff > _epsilon) {
      mismatchDescription.add('min corner is at distance $minDiff\n');
    }
    if (maxDiff > _epsilon) {
      mismatchDescription.add('max corner is at distance $maxDiff\n');
    }
    return mismatchDescription.add(
      'Aabb2([${item.min.x}, ${item.min.y}]..[${item.max.x}, ${item.max.y}])',
    );
  }
}
