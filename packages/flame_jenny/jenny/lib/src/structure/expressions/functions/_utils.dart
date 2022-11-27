import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/bool.dart';
import 'package:jenny/src/structure/expressions/functions/ceil.dart';
import 'package:jenny/src/structure/expressions/functions/dec.dart';
import 'package:jenny/src/structure/expressions/functions/decimal.dart';
import 'package:jenny/src/structure/expressions/functions/dice.dart';
import 'package:jenny/src/structure/expressions/functions/floor.dart';
import 'package:jenny/src/structure/expressions/functions/inc.dart';
import 'package:jenny/src/structure/expressions/functions/int.dart';
import 'package:jenny/src/structure/expressions/functions/number.dart';
import 'package:jenny/src/structure/expressions/functions/plural.dart';
import 'package:jenny/src/structure/expressions/functions/random.dart';
import 'package:jenny/src/structure/expressions/functions/random_range.dart';
import 'package:jenny/src/structure/expressions/functions/round.dart';
import 'package:jenny/src/structure/expressions/functions/round_places.dart';
import 'package:jenny/src/structure/expressions/functions/string.dart';
import 'package:jenny/src/structure/expressions/functions/visit_count.dart';
import 'package:jenny/src/structure/expressions/functions/visited.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:meta/meta.dart';

typedef ErrorFn = Never Function(String message, [int? position]);

class FunctionArgument {
  FunctionArgument(this.expression, this.position);
  final Expression expression;
  final int position;
}

typedef FunctionBuilder = Expression Function(
  List<FunctionArgument>,
  YarnProject,
  ErrorFn,
);

const Map<String, FunctionBuilder> builtinFunctions = {
  'bool': BoolFn.make,
  'ceil': CeilFn.make,
  'dec': DecFn.make,
  'decimal': DecimalFn.make,
  'dice': DiceFn.make,
  'floor': FloorFn.make,
  'inc': IncFn.make,
  'int': IntFn.make,
  'number': NumberFn.make,
  'plural': PluralFn.make,
  'random': RandomFn.make,
  'random_range': RandomRangeFn.make,
  'round': RoundFn.make,
  'round_places': RoundPlacesFn.make,
  'string': StringFn.make,
  'visit_count': VisitCountFn.make,
  'visited_count': VisitCountFn.make,
  'visited': VisitedFn.make,
};

@internal
Expression num1Builder(
  String name,
  Expression Function(NumExpression) constructor,
  List<FunctionArgument> args,
  ErrorFn errorFn,
) {
  if (args.length != 1) {
    errorFn(
      'function $name() requires a single argument',
      args.isEmpty ? null : args[1].position,
    );
  }
  if (!args[0].expression.isNumeric) {
    errorFn('the argument in $name() should be numeric', args[0].position);
  }
  return constructor(args[0].expression as NumExpression);
}
