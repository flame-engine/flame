import 'package:flame_yarn/src/runner/dialogue_runner.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class SetCommand extends Command {
  const SetCommand(this.variable, this.expression);

  final String variable;
  final Expression expression;

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.project.variables.setVariable(variable, expression.value);
  }
}
