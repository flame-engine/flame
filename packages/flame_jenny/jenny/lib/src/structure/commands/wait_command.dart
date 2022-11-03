import 'package:jenny/src/runner/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class WaitCommand extends Command {
  const WaitCommand(this.arg);

  final NumExpression arg;

  @override
  Future<void> execute(DialogueRunner dialogue) {
    final duration = Duration(
      microseconds: (arg.value.toDouble() * 1000000).toInt(),
    );
    return Future.delayed(duration);
  }
}
