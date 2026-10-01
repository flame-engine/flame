import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/variable_storage.dart';

class const NumericVariable(final String name, final VariableStorage storage)
    extends NumExpression {
  @override
  num get value => storage.getNumericValue(name);
}

class const StringVariable(final String name, final VariableStorage storage)
    extends StringExpression {
  @override
  String get value => storage.getStringValue(name);
}

class const BooleanVariable(final String name, final VariableStorage storage)
    extends BoolExpression {
  @override
  bool get value => storage.getBooleanValue(name);
}
