import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

/// [DialogueLine] is a single line of "normal" text within the dialogue.
///
/// A dialogue line may contain a [character] (the name of the entity who is
/// speaking), and [tags] -- a list of hashtag tokens that specify some meta
/// information about the line.
///
/// Example of a dialogue line in yarn script:
/// ```yarn
/// Hermione: Holy cricket! You're Harry Potter.  #surprised
/// ```
class DialogueLine extends DialogueEntry {
  const DialogueLine({
    this.character,
    required this.content,
    this.tags,
  });

  /// The name of the character who is speaking the line. This can be null if
  /// the line does not indicate the speaker.
  final String? character;
  final StringExpression content;
  final List<String>? tags;

  @override
  Future<void> processInDialogueRunner(DialogueRunner runner) {
    return runner.deliverLine(this);
  }

  void _evaluateLine() {}

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    return 'DialogueLine($prefix${content.value})';
  }
}
