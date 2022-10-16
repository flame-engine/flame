
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/variable_storage.dart';


class NumericVariable extends TypedExpression<num> {
  const NumericVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  num get value => storage.getNumericValue(name);
}

class StringVariable extends TypedExpression<String> {
  const StringVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  String get value => storage.getStringValue(name);
}

class BooleanVariable extends TypedExpression<bool> {
  const BooleanVariable(this.name, this.storage);

  final String name;
  final VariableStorage storage;

  @override
  bool get value => storage.getBooleanValue(name);
}
