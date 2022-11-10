import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class WaitCommand extends Command {
  const WaitCommand(this.arg);

  final NumExpression arg;

  @override
  String get name => 'wait';

  @override
  Future<void> execute(DialogueRunner dialogue) {
    final duration = Duration(
      microseconds: (arg.value.toDouble() * 1000000).toInt(),
    );
    return Future.delayed(duration);
  }
}
