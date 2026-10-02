import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class const StopCommand() extends Command {
  @override
  String get name => 'stop';

  @override
  void execute(DialogueRunner dialogue) {
    dialogue.jumpToNode(null);
  }
}
