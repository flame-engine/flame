import 'package:jenny/src/runner/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class StopCommand extends Command {
  const StopCommand();

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.stop();
  }
}
