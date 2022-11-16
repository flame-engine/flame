import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/expressions/expression.dart';

class DialogueLine extends DialogueEntry {
  const DialogueLine({
    this.character,
    required this.content,
    this.tags,
  });

  final String? character;
  final StringExpression content;
  final List<String>? tags;

  @override
  Future<void> processInDialogueRunner(DialogueRunner runner) {
    return runner.deliverLine(this);
  }

  @override
  String toString() {
    final prefix = character == null ? '' : '$character: ';
    return 'DialogueLine($prefix${content.value})';
  }
}
