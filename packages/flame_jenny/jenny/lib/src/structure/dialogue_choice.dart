import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/dialogue_option.dart';

class DialogueChoice extends DialogueEntry {
  const DialogueChoice(this.options);

  final List<DialogueOption> options;

  @override
  Future<void> processInDialogueRunner(DialogueRunner runner) {
    for (final option in options) {
      option.evaluate();
    }
    return runner.deliverChoices(this);
  }

  @override
  String toString() => 'DialogueChoice($options)';
}
