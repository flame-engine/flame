import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class const JumpCommand(final StringExpression target) extends Command {
  @override
  String get name => 'jump';

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.jumpToNode(target.value);
  }
}
