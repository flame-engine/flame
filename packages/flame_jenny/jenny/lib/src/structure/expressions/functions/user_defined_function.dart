import 'package:jenny/src/function_storage.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

/// Expression for a user-defined function that returns a numeric result.
class NumericUserDefinedFn extends NumExpression {
  NumericUserDefinedFn(this._udf, this._arguments);

  final Udf _udf;
  final List<Expression> _arguments;

  @override
  num get value => _udf.run(_arguments) as num;
}

/// Expression for a user-defined function that returns a boolean result.
class BooleanUserDefinedFn extends BoolExpression {
  BooleanUserDefinedFn(this._udf, this._arguments);

  final Udf _udf;
  final List<Expression> _arguments;

  @override
  bool get value => _udf.run(_arguments) as bool;
}

/// Expression for a user-defined function that returns a string result.
class StringUserDefinedFn extends StringExpression {
  StringUserDefinedFn(this._udf, this._arguments);

  final Udf _udf;
  final List<Expression> _arguments;

  @override
  String get value => _udf.run(_arguments) as String;
}
