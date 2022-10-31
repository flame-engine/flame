import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/yarn_project.dart';

class WaitCommand extends Command {
  const WaitCommand(this.arg);

  final NumExpression arg;

  @override
  void execute(YarnProject project) {
    project.wait(arg.value.toDouble());
  }
}
