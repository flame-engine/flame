import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/errors.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class WaitCommand extends Command {
  const WaitCommand(this.arg);

  final NumExpression arg;

  @override
  String get name => 'wait';

  @override
  Future<void> execute(DialogueRunner dialogue) {
    final seconds = arg.value.toDouble();
    if (seconds < 0) {
      throw DialogueError('<<wait>> command with negative duration: $seconds');
    }
    return Future.delayed(
      Duration(microseconds: (seconds * 1000000).toInt()),
    );
  }
}
