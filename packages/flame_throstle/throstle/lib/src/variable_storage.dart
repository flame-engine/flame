import 'package:throstle/src/structure/expressions/expression_type.dart';

class VariableStorage {
  final Map<String, dynamic> variables = <String, dynamic>{};

  int get length => variables.length;
  bool get isEmpty => variables.isEmpty;
  bool get isNotEmpty => variables.isNotEmpty;

  bool getBooleanValue(String name) => variables[name]! as bool;
  num getNumericValue(String name) => variables[name]! as num;
  String getStringValue(String name) => variables[name]! as String;

  bool hasVariable(String name) => variables.containsKey(name);
  dynamic getVariable(String name) => variables[name]!;

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
    variables[name] = value;
  }
}
