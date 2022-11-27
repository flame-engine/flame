import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class StopCommand extends Command {
  const StopCommand();

  @override
  String get name => 'stop';

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.stop();
  }
}
