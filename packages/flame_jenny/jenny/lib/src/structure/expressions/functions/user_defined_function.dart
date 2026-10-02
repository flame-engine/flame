import 'package:jenny/src/function_storage.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

/// Expression for a user-defined function that returns a numeric result.
class NumericUserDefinedFn(final Udf _udf, final List<Expression> _arguments)
    extends NumExpression {
  @override
  num get value => _udf.run(_arguments) as num;
}

/// Expression for a user-defined function that returns a boolean result.
class BooleanUserDefinedFn(final Udf _udf, final List<Expression> _arguments)
    extends BoolExpression {
  @override
  bool get value => _udf.run(_arguments) as bool;
}

/// Expression for a user-defined function that returns a string result.
class StringUserDefinedFn(final Udf _udf, final List<Expression> _arguments)
    extends StringExpression {
  @override
  String get value => _udf.run(_arguments) as String;
}
