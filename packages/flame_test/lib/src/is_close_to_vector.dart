import 'package:flutter_test/flutter_test.dart';

abstract class IsCloseToVector<V> extends Matcher {
  const IsCloseToVector(this._value, this._epsilon);

  final V _value;
  final double _epsilon;

  double dist(V a, V b);
  List<double> storage(V value);

  @override
  bool matches(dynamic item, Map matchState) {
    return (item is V) && dist(item, _value) <= _epsilon;
  }

  @override
  Description describe(Description description) {
    final coords = storage(_value).join(', ');
    return description.add('a $V object within $_epsilon of ($coords)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! V) {
      return mismatchDescription.add('is not an instance of $V');
    }
    final distance = dist(item, _value);
    return mismatchDescription.add('is at distance $distance');
  }
}
