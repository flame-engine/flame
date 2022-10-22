import 'dart:math';

import 'package:flame_yarn/src/structure/expressions/expression.dart';

Random $randomGenerator = Random();

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

class RandomFn extends NumExpression {
  const RandomFn();

  @override
  num get value => $randomGenerator.nextDouble();
}

class RandomRangeFn extends NumExpression {
  const RandomRangeFn(this.a, this.b);

  final NumExpression a;
  final NumExpression b;

  @override
  num get value {
    final lower = a.value.toInt();
    final upper = b.value.toInt();
    return $randomGenerator.nextInt(upper - lower + 1) + lower;
  }
}

class DiceFn extends NumExpression {
  const DiceFn(this.sides);

  final NumExpression sides;

  @override
  num get value => $randomGenerator.nextInt(sides.value.toInt()) + 1;
}

class RoundFn extends NumExpression {
  const RoundFn(this.arg);

  final NumExpression arg;

  @override
  num get value => arg.value.round();
}

class RoundPlacesFn extends NumExpression {
  const RoundPlacesFn(this.arg, this.places);

  final NumExpression arg;
  final NumExpression places;

  @override
  num get value {
    final precision = places.value.toInt();
    final factor = pow(10, precision);
    return (arg.value * factor).roundToDouble() / factor;
  }
}

class FloorFn extends NumExpression {
  const FloorFn(this.arg);

  final NumExpression arg;

  @override
  num get value => arg.value.floor();
}

class CeilFn extends NumExpression {
  const CeilFn(this.arg);

  final NumExpression arg;

  @override
  num get value => arg.value.ceil();
}

class IncFn extends NumExpression {
  const IncFn(this.arg);

  final NumExpression arg;

  @override
  num get value => arg.value.toInt() + 1;
}

class DecFn extends NumExpression {
  const DecFn(this.arg);

  final NumExpression arg;

  @override
  num get value {
    final x = arg.value;
    final y = x.toInt();
    return x == y ? y - 1 : y;
  }
}

class DecimalFn extends NumExpression {
  const DecimalFn(this.arg);

  final NumExpression arg;

  @override
  num get value {
    final x = arg.value;
    return x - x.floor();
  }
}

class IntFn extends NumExpression {
  const IntFn(this.arg);

  final NumExpression arg;

  @override
  num get value => arg.value.truncate();
}

/// Function `string(num x)`.
class NumToStringFn extends StringExpression {
  const NumToStringFn(this.arg);

  final NumExpression arg;

  @override
  String get value => arg.value.toString();
}

/// Function `string(bool x)`.
class BoolToStringFn extends StringExpression {
  const BoolToStringFn(this.arg);

  final BoolExpression arg;

  @override
  String get value => arg.value.toString();
}

/// Function `number(String x)`.
class StringToNumFn extends NumExpression {
  const StringToNumFn(this.arg);

  final StringExpression arg;

  @override
  num get value => double.parse(arg.value);
}

/// Function `bool(num x)`.
class NumToBoolFn extends BoolExpression {
  const NumToBoolFn(this.arg);

  final NumExpression arg;

  @override
  bool get value => arg.value != 0;
}
