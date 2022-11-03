import 'package:jenny/src/runner/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class JumpCommand extends Command {
  const JumpCommand(this.target);

  final StringExpression target;

  @override
  Future<void> execute(DialogueRunner dialogue) {
    return dialogue.jumpToNode(target.value);
  }
}
