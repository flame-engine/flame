import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class const CharacterCommand() extends Command {
  @override
  String get name => 'character';

  @override
  void execute(DialogueRunner dialogue) => throw AssertionError();
}
