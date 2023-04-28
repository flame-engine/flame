import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class CharacterCommand extends Command {
  const CharacterCommand();

  @override
  String get name => 'character';

  @override
  void execute(DialogueRunner dialogue) => throw AssertionError();
}
