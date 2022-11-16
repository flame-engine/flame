import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';
import 'package:jenny/src/structure/option.dart';

class DialogueChoice extends DialogueEntry {
  const DialogueChoice(this.options);

  final List<Option> options;

  @override
  Future<void> processInDialogueRunner(DialogueRunner runner) {
    return runner.deliverChoices(this);
  }

  @override
  String toString() => 'DialogueChoice($options)';
}
