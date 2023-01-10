import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

Expression makeIfFn(
  List<FunctionArgument> args,
  YarnProject yarnProject,
  ErrorFn errorFn,
) {
  if (args.length != 3) {
    errorFn(
      'function if() requires three arguments',
      args.length < 3 ? null : args[3].position,
    );
  }
  if (!args[0].expression.isBoolean) {
    errorFn(
      'first argument in if() should be a boolean condition',
      args[0].position,
    );
  }
  final type1 = args[1].expression.type;
  final type2 = args[2].expression.type;
  if (type1 != type2) {
    errorFn(
      'the types of the second and the third arguments in if() must be the '
      'same, instead they were ${type1.name} and ${type2.name}',
      args[2].position,
    );
  }
  if (args[1].expression.isBoolean) {
    return _IfFnBoolean(
      args[0].expression as BoolExpression,
      args[1].expression as BoolExpression,
      args[2].expression as BoolExpression,
    );
  } else if (args[1].expression.isNumeric) {
    return _IfFnNumeric(
      args[0].expression as BoolExpression,
      args[1].expression as NumExpression,
      args[2].expression as NumExpression,
    );
  } else {
    assert(args[1].expression.isString);
    return _IfFnString(
      args[0].expression as BoolExpression,
      args[1].expression as StringExpression,
      args[2].expression as StringExpression,
    );
  }
}

class _IfFnBoolean extends BoolExpression {
  _IfFnBoolean(this._condition, this._then, this._else);

  final BoolExpression _condition;
  final BoolExpression _then;
  final BoolExpression _else;

  @override
  bool get value => _condition.value ? _then.value : _else.value;
}

class _IfFnNumeric extends NumExpression {
  _IfFnNumeric(this._condition, this._then, this._else);

  final BoolExpression _condition;
  final NumExpression _then;
  final NumExpression _else;

  @override
  num get value => _condition.value ? _then.value : _else.value;
}

class _IfFnString extends StringExpression {
  _IfFnString(this._condition, this._then, this._else);

  final BoolExpression _condition;
  final StringExpression _then;
  final StringExpression _else;

  @override
  String get value => _condition.value ? _then.value : _else.value;
}
