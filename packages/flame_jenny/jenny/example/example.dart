import 'dart:io';

import 'package:jenny/jenny.dart';

const yarn = '''
<<character Jenny>>
<<character Player>>

title: Start
---
Jenny: Hi there, welcome to the tavern!
Jenny: What can I get you?
-> Player: Some water, please.
    Jenny: Coming right up.
-> Player: Nothing, thanks.
    Jenny: Suit yourself.
===
''';

Future<void> main() async {
  final project = YarnProject()..parse(yarn);
  final runner = DialogueRunner(
    yarnProject: project,
    dialogueViews: [ConsoleDialogueView()],
  );
  await runner.startDialogue('Start');
}

class ConsoleDialogueView() extends DialogueView {
  @override
  bool onLineStart(DialogueLine line) {
    stdout.writeln('${line.character?.name}: ${line.text}');
    return true;
  }

  @override
  int onChoiceStart(DialogueChoice choice) {
    for (final (index, option) in choice.options.indexed) {
      stdout.writeln('  ${index + 1}. ${option.text}');
    }
    return 0;
  }
}
