import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/variables.dart';

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

  Expression getVariableAsExpression(String name) {
    final dynamic value = variables[name];
    return switch (value) {
      String() => StringVariable(name, this),
      num() => NumericVariable(name, this),
      bool() => BooleanVariable(name, this),
      _ => throw DialogueError(
        'Cannot convert variable $name with type ${value.runtimeType} to '
        'an expression',
      ),
    };
  }

  ExpressionType getVariableType(String name) {
    final dynamic value = variables[name];
    return switch (value) {
      String() => ExpressionType.string,
      num() => ExpressionType.numeric,
      bool() => ExpressionType.boolean,
      _ => ExpressionType.unknown,
    };
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

  /// Clear all variables. By default node visit counts will not be cleared.
  /// To remove node visit counts as well, set [clearNodeVisits] to `true`.
  ///
  /// Note that node visit variable names are prefixed with an @ symbol.
  /// If you have custom variables that start with an @ symbol these will
  /// also be retained if [clearNodeVisits] is `false`. These will need to be
  /// removed individually using [remove].
  void clear({bool clearNodeVisits = false}) {
    if (!clearNodeVisits) {
      variables.removeWhere((key, _) => !key.startsWith('@'));
    } else {
      variables.clear();
    }
  }

  /// Remove a variable by [name].
  void remove(String name) {
    variables.remove(name);
  }
}
