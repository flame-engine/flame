
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';
import 'package:flame_yarn/src/yarn_project.dart';

class SetCommand extends Command {
  const SetCommand(this.variable, this.expression);

  final String variable;
  final Expression expression;

  @override
  void execute(YarnProject runtime) {
    runtime.variables.setVariable(variable, expression.value);
  }
}
