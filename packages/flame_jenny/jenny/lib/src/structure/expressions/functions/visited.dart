import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

class VisitedFn extends BoolExpression {
  VisitedFn(this._node, this._yarn);

  final StringExpression _node;
  final YarnProject _yarn;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function visited() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    if (!args[0].expression.isString) {
      errorFn('the argument should be a string', args[0].position);
    }
    return VisitedFn(args[0].expression as StringExpression, yarnProject);
  }

  @override
  bool get value {
    final node = _node.value;
    final variableName = '@$node';
    if (_yarn.variables.hasVariable(variableName)) {
      final visitCount = _yarn.variables.getNumericValue(variableName);
      return visitCount > 0;
    } else {
      throw DialogueError('Unknown node name "$node"');
    }
  }
}
