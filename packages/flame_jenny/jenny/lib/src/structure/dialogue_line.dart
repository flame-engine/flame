import 'package:jenny/jenny.dart';
import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/line_content.dart';

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
  DialogueLine({
    required LineContent content,
    this.character,
    this.tags,
  }) : _content = content;

  /// The name of the character who is speaking the line. This can be null if
  /// the line does not indicate the speaker.
  final String? character;
  final List<String>? tags;
  final LineContent _content;

  String get value => _value ??= _evaluateLine();
  String? _value;

  @override
  Future<void> processInDialogueRunner(DialogueRunner runner) {
    return runner.deliverLine(this);
  }

  String _evaluateLine() {
    return _content.evaluate();
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    return 'DialogueLine($prefix$value)';
  }

  @override
  bool operator ==(Object other) =>
      other is DialogueLine &&
      value == other.value &&
      character == other.character;
}
