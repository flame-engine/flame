import 'package:flame_yarn/src/runner/dialogue_runner.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';

class JumpCommand extends Command {
  const JumpCommand(this.target);

  final StringExpression target;

  @override
  Future<void> execute(DialogueRunner dialogue) {
    return dialogue.jumpToNode(target.value);
  }
}
