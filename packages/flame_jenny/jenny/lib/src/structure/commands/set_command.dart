import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class SetCommand extends Command {
  const SetCommand(this.variable, this.expression);

  final String variable;
  final Expression expression;

  @override
  String get name => 'set';

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.project.variables.setVariable(variable, expression.value);
  }
}
