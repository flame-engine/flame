import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

class DeclareCommand extends Command {
  const DeclareCommand();

  @override
  String get name => 'declare';

  @override
  void execute(DialogueRunner dialogue) {
    throw UnsupportedError('<<declare>> command is not executable');
  }
}
