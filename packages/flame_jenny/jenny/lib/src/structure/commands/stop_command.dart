import 'package:flame_yarn/src/runner/dialogue_runner.dart';
import 'package:flame_yarn/src/structure/commands/command.dart';

class StopCommand extends Command {
  const StopCommand();

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.stop();
  }
}
