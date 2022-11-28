import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/variables.dart';
import 'package:meta/meta.dart';

class VariableStorage {
  @protected
  final Map<String, dynamic> variables = <String, dynamic>{};

  int get length => variables.length;
  bool get isEmpty => variables.isEmpty;
  bool get isNotEmpty => variables.isNotEmpty;

  bool getBooleanValue(String name) => variables[name]! as bool;
  num getNumericValue(String name) => variables[name]! as num;
  String getStringValue(String name) => variables[name]! as String;

  bool hasVariable(String name) => variables.containsKey(name);
  dynamic getVariable(String name) => variables[name]!;

  Expression getVariableAsExpression(String name) {
    final dynamic value = variables[name];
    if (value is String) {
      return StringVariable(name, this);
    }
    if (value is num) {
      return NumericVariable(name, this);
    }
    assert(value is bool);
    return BooleanVariable(name, this);
  }

  ExpressionType getVariableType(String name) {
    final dynamic value = variables[name];
    return value is String
        ? ExpressionType.string
        : value is num
            ? ExpressionType.numeric
            : value is bool
                ? ExpressionType.boolean
                : ExpressionType.unknown;
  }

  void setVariable(String name, dynamic value) {
    final dynamic oldValue = variables[name];
    if (!(value is String || value is num || value is bool)) {
      throw DialogueError(
        'Cannot set variable $name to a value with type ${value.runtimeType}',
      );
    }
    if (oldValue != null &&
        !(value is String && oldValue is String) &&
        !(value is num && oldValue is num) &&
        !(value is bool && oldValue is bool)) {
      throw DialogueError(
        'Redefinition of variable $name from type ${oldValue.runtimeType} to '
        '${value.runtimeType} is not allowed',
      );
    }
    variables[name] = value;
  }
}
