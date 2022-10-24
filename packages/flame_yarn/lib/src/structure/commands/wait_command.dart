import 'package:flame_yarn/src/dialogue_runner.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/expressions/expression.dart';

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
