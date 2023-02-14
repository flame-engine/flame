import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

class VisitCountFn extends NumExpression {
  VisitCountFn(this._node, this._yarn);

  final StringExpression _node;
  final YarnProject _yarn;

  static Expression make(
    List<FunctionArgument> args,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    if (args.length != 1) {
      errorFn(
        'function visit_count() requires a single argument',
        args.isEmpty ? null : args[1].position,
      );
    }
    if (!args[0].expression.isString) {
      errorFn('the argument should be a string', args[0].position);
    }
    return VisitCountFn(args[0].expression as StringExpression, yarnProject);
  }

  @override
  num get value {
    final node = _node.value;
    final variableName = '@$node';
    if (_yarn.variables.hasVariable(variableName)) {
      return _yarn.variables.getNumericValue(variableName);
    } else {
      throw DialogueError('Unknown node name "$node"');
    }
  }
}
