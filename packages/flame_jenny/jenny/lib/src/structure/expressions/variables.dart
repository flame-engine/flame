import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/variable_storage.dart';

class NumericVariable extends NumExpression {
  const NumericVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  num get value => storage.getNumericValue(name);
}

class StringVariable extends StringExpression {
  const StringVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  String get value => storage.getStringValue(name);
}

class BooleanVariable extends BoolExpression {
  const BooleanVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  bool get value => storage.getBooleanValue(name);
}
