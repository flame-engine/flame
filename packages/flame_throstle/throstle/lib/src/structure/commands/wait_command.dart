import 'package:throstle/src/structure/commands/command.dart';
import 'package:throstle/src/structure/expressions/expression.dart';
import 'package:throstle/src/yarn_project.dart';

class WaitCommand extends Command {
  const WaitCommand(this.arg);

  final NumExpression arg;

  @override
  void execute(YarnProject project) {
    project.wait(arg.value.toDouble());
  }
}
