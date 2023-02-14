import 'dart:math';

import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

/// Function `round_places(x, n)` will round `x` to `n` decimal places.
class RoundPlacesFn extends NumExpression {
  const RoundPlacesFn(this.arg, this.places);

  final NumExpression arg;
  final NumExpression places;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 2) {
      errorFn(
        'function round_places() requires two arguments',
        args.length < 2 ? null : args[2].position,
      );
    }
    if (!args[0].expression.isNumeric) {
      errorFn(
        'first argument in round_places() should be numeric',
        args[0].position,
      );
    }
    if (!args[1].expression.isNumeric) {
      errorFn(
        'second argument in round_places() should be numeric',
        args[1].position,
      );
    }
    return RoundPlacesFn(
      args[0].expression as NumExpression,
      args[1].expression as NumExpression,
    );
  }

  @override
  num get value {
    final precision = places.value.toInt();
    final factor = pow(10, precision);
    return (arg.value * factor).roundToDouble() / factor;
  }
}
