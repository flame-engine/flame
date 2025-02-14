import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

/// Returns a matcher which checks if each entry in a 4x4 matrix is within
/// a distance [epsilon] of the corresponding entry in [matrix].
///
/// For example:
///
/// ```dart
/// expect(
///   transform,
///   closeToMatrix4(
///     Matrix4.columns(
///       Vector4(0, -1, 0, 0),
///       Vector4(1, 0, 0, 0),
///       Vector4(0, 0, 1, 0),
///       Vector4(0, 0, 0, 1),
///     ),
///   ),
/// );
/// ```
Matcher closeToMatrix4(Matrix4 matrix, [double epsilon = 1e-15]) {
  return _IsCloseTo(matrix, epsilon);
}

class _IsCloseTo extends Matcher {
  const _IsCloseTo(this._value, this._epsilon);

  final Matrix4 _value;
  final double _epsilon;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Matrix4) {
      return false;
    }
    for (var i = 0; i < 15; i++) {
      if ((_value[i] - item[i]).abs() > _epsilon) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    final entries = _value.storage.join(', ');
    return description.add('a Matrix4 object within $_epsilon of ($entries)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Matrix4) {
      return mismatchDescription.add('is not an instance of Matrix4');
    }
    final entries = _value.storage.join(', ');
    return mismatchDescription.add('is not within $_epsilon of ($entries)');
  }
}
