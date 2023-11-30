import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/dialogue_entry.dart';

abstract class Command extends DialogueEntry {
  const Command();

  FutureOr<void> execute(DialogueRunner dialogue);

  String get name;

  @override
  Future<void> processInDialogueRunner(DialogueRunner dialogueRunner) {
    return dialogueRunner.deliverCommand(this);
  }
}
