import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/yarn_project.dart';

class SetCommand extends Command {
  const SetCommand(this.variable, this.expression);

  final String variable;
  final Expression expression;

  @override
  void execute(YarnProject runtime) {
    runtime.variables.setVariable(variable, expression.value);
  }
}
