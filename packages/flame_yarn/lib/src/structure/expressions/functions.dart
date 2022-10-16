import 'dart:math';

import 'package:flame_yarn/src/structure/expressions/expression.dart';

Random $randomGenerator = Random();

// TODO(st-pasha): visited(String nodeName)
// TODO(st-pasha): visited_count(String nodeName)

class RandomFn extends TypedExpression<num> {
  const RandomFn();

  @override
  num get value => $randomGenerator.nextDouble();
}

class RandomRangeFn extends TypedExpression<num> {
  const RandomRangeFn(this.a, this.b);

  final TypedExpression<num> a;
  final TypedExpression<num> b;

  @override
  num get value {
    final lower = a.value.toInt();
    final upper = b.value.toInt();
    return $randomGenerator.nextInt(upper - lower + 1) + lower;
  }
}

class DiceFn extends TypedExpression<num> {
  const DiceFn(this.sides);

  final TypedExpression<num> sides;

  @override
  num get value => $randomGenerator.nextInt(sides.value.toInt()) + 1;
}

class RoundFn extends TypedExpression<num> {
  const RoundFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => arg.value.round();
}

class RoundPlacesFn extends TypedExpression<num> {
  const RoundPlacesFn(this.arg, this.places);

  final TypedExpression<num> arg;
  final TypedExpression<num> places;

  @override
  num get value {
    final precision = places.value.toInt();
    final factor = pow(10, precision);
    return (arg.value * factor).roundToDouble() / factor;
  }
}

class FloorFn extends TypedExpression<num> {
  const FloorFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => arg.value.floor();
}

class CeilFn extends TypedExpression<num> {
  const CeilFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => arg.value.ceil();
}

class IncFn extends TypedExpression<num> {
  const IncFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => arg.value.toInt() + 1;
}

class DecFn extends TypedExpression<num> {
  const DecFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value {
    final x = arg.value;
    final y = x.toInt();
    return x == y ? y - 1 : y;
  }
}

class DecimalFn extends TypedExpression<num> {
  const DecimalFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value {
    final x = arg.value;
    return x - x.floor();
  }
}

class IntFn extends TypedExpression<num> {
  const IntFn(this.arg);

  final TypedExpression<num> arg;

  @override
  num get value => arg.value.truncate();
}

/// Function `string(num x)`.
class NumToStringFn extends TypedExpression<String> {
  const NumToStringFn(this.arg);

  final TypedExpression<num> arg;

  @override
  String get value => arg.value.toString();
}

/// Function `string(bool x)`.
class BoolToStringFn extends TypedExpression<String> {
  const BoolToStringFn(this.arg);

  final TypedExpression<bool> arg;

  @override
  String get value => arg.value.toString();
}

/// Function `number(String x)`.
class StringToNumFn extends TypedExpression<num> {
  const StringToNumFn(this.arg);

  final TypedExpression<String> arg;

  @override
  num get value => double.parse(arg.value);
}

/// Function `bool(num x)`.
class NumToBoolFn extends TypedExpression<bool> {
  const NumToBoolFn(this.arg);

  final TypedExpression<num> arg;

  @override
  bool get value => arg.value != 0;
}
