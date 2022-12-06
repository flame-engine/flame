import 'dart:async';

import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:test/test.dart';

import 'test_scenario.dart';

void main() {
  group('DialogueView', () {
    test('run a sample dialogue', () async {
      final yarn = YarnProject()
        ..commands.addDialogueCommand('myCommand')
        ..parse(
          dedent('''
            title: Start
            ---
            First line
            -> Option 1
                Continuation line 1
            -> Option 2
                Continuation line 2
            Last line
            <<myCommand 123 boo>>
            ===
          '''),
        );
      final view1 = _DefaultDialogueView();
      final view2 = _RecordingDialogueView();
      final dialogueRunner = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2],
      );
      await dialogueRunner.runNode('Start');
      expect(
        view2.events,
        const [
          'onDialogueStart',
          'onNodeStart(Start)',
          'onLineStart(First line)',
          'onLineFinish(First line)',
          'onChoiceStart([-> Option 1][-> Option 2])',
          'onChoiceFinish(-> Option 2)',
          'onLineStart(Continuation line 2)',
          'onLineFinish(Continuation line 2)',
          'onLineStart(Last line)',
          'onLineFinish(Last line)',
          'onCommand(<<Command(myCommand)>>)',
          'onDialogueFinish()',
        ],
      );
    });

    test('stop line', () async {
      final yarn = YarnProject()
        ..parse(
          dedent('''
            title: Start
            ---
            First line
            ===
          '''),
        );
      final view1 = _DefaultDialogueView();
      final view2 = _RecordingDialogueView(const Duration(milliseconds: 500));
      final view3 = _InterruptingCow();
      final dialogueRunner = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2, view3],
      );
      await dialogueRunner.runNode('Start');
      expect(
        view2.events,
        const [
          'onDialogueStart',
          'onNodeStart(Start)',
          'onLineStart(First line)',
          'onLineSignal(line="First line", signal=<I\'m a banana!>)',
          'onLineStop(First line)',
          'onLineFinish(First line)',
          'onDialogueFinish()',
        ],
      );
    });
  });
}

class _DefaultDialogueView extends DialogueView {}

class _RecordingDialogueView extends DialogueView {
  _RecordingDialogueView([this.waitDuration = Duration.zero]);
  final List<String> events = [];
  final Duration waitDuration;

  @override
  FutureOr<void> onDialogueStart() {
    events.add('onDialogueStart');
  }

  @override
  FutureOr<void> onNodeStart(Node node) {
    events.add('onNodeStart(${node.title})');
  }

  @override
  FutureOr<bool> onLineStart(DialogueLine line) async {
    events.add('onLineStart(${line.text})');
    if (waitDuration != Duration.zero) {
      await Future.delayed(waitDuration, () {});
    }
    return true;
  }

  @override
  void onLineSignal(DialogueLine line, dynamic signal) {
    super.onLineSignal(line, signal);
    events.add('onLineSignal(line="${line.text}", signal=<$signal>)');
  }

  @override
  FutureOr<void> onLineStop(DialogueLine line) {
    super.onLineStop(line);
    events.add('onLineStop(${line.text})');
  }

  @override
  FutureOr<void> onLineFinish(DialogueLine line) {
    events.add('onLineFinish(${line.text})');
  }

  @override
  Future<int> onChoiceStart(DialogueChoice choice) async {
    final options =
        [for (final option in choice.options) '[-> ${option.text}]'].join();
    events.add('onChoiceStart($options)');
    return 1;
  }

  @override
  FutureOr<void> onChoiceFinish(DialogueOption option) {
    events.add('onChoiceFinish(-> ${option.text})');
  }

  @override
  FutureOr<void> onCommand(UserDefinedCommand command) {
    events.add('onCommand(<<$command>>)');
  }

  @override
  FutureOr<void> onDialogueFinish() {
    events.add('onDialogueFinish()');
  }
}

class _InterruptingCow extends DialogueView {
  @override
  FutureOr<bool> onLineStart(DialogueLine line) async {
    dialogueRunner.sendSignal("I'm a banana!");
    dialogueRunner.stopLine();
    return false;
  }
}
