import 'package:throstle/src/structure/commands/command.dart';
import 'package:throstle/src/structure/expressions/expression.dart';
import 'package:throstle/src/yarn_project.dart';

class JumpCommand extends Command {
  const JumpCommand(this.target);

  final StringExpression target;

  @override
  void execute(YarnProject project) {
    project.jumpToNode(target.value);
  }
}
