import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/structure/dialogue_choice.dart';
import 'package:jenny/src/structure/dialogue_line.dart';

/// Base class for all entries in a dialogue.
///
/// Each entry is processed independently and sequentially by the dialogue
/// runner, as if they were statements in a program.
///
/// There are 3 kinds of dialogue entries:
/// - [Command]
/// - [DialogueChoice]
/// - [DialogueLine]
abstract class DialogueEntry {
  const DialogueEntry();

  /// Runs the entry within the context of a dialogue runner.
  ///
  /// This method is invoked by the [dialogueRunner] itself, at the right time.
  Future<void> processInDialogueRunner(DialogueRunner dialogueRunner);
}
