import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';

/// The `<<declare>>` command in yarn script.
///
/// The purpose of this command is to introduce a new variable, giving it a
/// specific type and initial value. All variables must be declared via this
/// command before they can be used.
///
/// The `<<declare>>` command can only appear outside of nodes (at the "root"
/// level of the file), and it is executed at compile-time. For this reason the
/// [DeclareCommand] class has no content: it is only used internally during
/// parsing, and will never be seen by a dialogue runner.
///
/// The command itself can take one of the several forms:
/// ```
/// <<declare $variable = 7>>
/// <<declare $variable as Number>>  // initial value will be 0
/// <<declare $variable = 7 as Number>>
/// ```
class DeclareCommand extends Command {
  const DeclareCommand();

  @override
  String get name => 'declare';

  @override
  void execute(DialogueRunner dialogue) => throw AssertionError();
}
