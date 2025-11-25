import 'dart:async';

import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import 'test_scenario.dart';
import 'utils.dart';

void main() {
  group('DialogueView', () {
    test('run a sample dialogue', () async {
      final yarn = YarnProject()
        ..commands.addOrphanedCommand('myCommand')
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
      await dialogueRunner.startDialogue('Start');
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
          'onCommandFinish(<<Command(myCommand)>>)',
          'onNodeFinish(Start)',
          'onDialogueFinish()',
        ],
      );
    });

    test('run a sample dialogue using mixin', () async {
      final yarn = YarnProject()
        ..commands.addOrphanedCommand('myCommand')
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
      final view2 = _RecordingDialogueViewAsMixin();
      final dialogueRunner = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2],
      );
      await dialogueRunner.startDialogue('Start');
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
          'onCommandFinish(<<Command(myCommand)>>)',
          'onNodeFinish(Start)',
          'onDialogueFinish()',
        ],
      );
    });

    test('jumps and visits', () async {
      final yarn = YarnProject()
        ..parse(
          dedent('''
            title: Start
            ---
            First line
            <<visit AnotherNode>>
            Second line
            <<jump SomewhereElse>>
            ===
            title: AnotherNode
            ---
            Inside another node
            <<jump SomewhereElse>>
            ===
            title: SomewhereElse
            ---
            This is nowhere...
            ===
          '''),
        );
      final view1 = _DefaultDialogueView();
      final view2 = _RecordingDialogueView();
      final dialogueRunner = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2],
      );
      await dialogueRunner.startDialogue('Start');
      expect(
        view2.events,
        const [
          'onDialogueStart',
          'onNodeStart(Start)',
          'onLineStart(First line)',
          'onLineFinish(First line)',
          'onNodeStart(AnotherNode)',
          'onLineStart(Inside another node)',
          'onLineFinish(Inside another node)',
          'onNodeFinish(AnotherNode)',
          'onNodeStart(SomewhereElse)',
          'onLineStart(This is nowhere...)',
          'onLineFinish(This is nowhere...)',
          'onNodeFinish(SomewhereElse)',
          'onLineStart(Second line)',
          'onLineFinish(Second line)',
          'onNodeFinish(Start)',
          'onNodeStart(SomewhereElse)',
          'onLineStart(This is nowhere...)',
          'onLineFinish(This is nowhere...)',
          'onNodeFinish(SomewhereElse)',
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
      await dialogueRunner.startDialogue('Start');
      expect(
        view2.events,
        const [
          'onDialogueStart',
          'onNodeStart(Start)',
          'onLineStart(First line)',
          'onLineSignal(line="First line", signal=<I\'m a banana!>)',
          'onLineStop(First line)',
          'onLineFinish(First line)',
          'onNodeFinish(Start)',
          'onDialogueFinish()',
        ],
      );
    });

    test('dialogue view cannot be attached to two dialogue runners', () {
      final yarn = YarnProject()..parse('title:A\n---\nOne\n===\n');
      final view = _DefaultDialogueView();
      final d1 = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      final d2 = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      expect(
        () async {
          await Future.wait([
            d1.startDialogue('A'),
            d2.startDialogue('A'),
          ]);
        },
        hasDialogueError(
          'DialogueView is currently attached to another DialogueRunner',
        ),
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
  FutureOr<void> onNodeFinish(Node node) {
    events.add('onNodeFinish(${node.title})');
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
    final options = [
      for (final option in choice.options) '[-> ${option.text}]',
    ].join();
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
  FutureOr<void> onCommandFinish(UserDefinedCommand command) {
    events.add('onCommandFinish(<<$command>>)');
  }

  @override
  FutureOr<void> onDialogueFinish() {
    events.add('onDialogueFinish()');
  }
}

class _SomeOtherBaseClass {}

class _RecordingDialogueViewAsMixin extends _SomeOtherBaseClass
    with DialogueView {
  _RecordingDialogueViewAsMixin();
  final List<String> events = [];

  @override
  FutureOr<void> onDialogueStart() {
    events.add('onDialogueStart');
  }

  @override
  FutureOr<void> onNodeStart(Node node) {
    events.add('onNodeStart(${node.title})');
  }

  @override
  FutureOr<void> onNodeFinish(Node node) {
    events.add('onNodeFinish(${node.title})');
  }

  @override
  FutureOr<bool> onLineStart(DialogueLine line) async {
    events.add('onLineStart(${line.text})');
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
    final options = [
      for (final option in choice.options) '[-> ${option.text}]',
    ].join();
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
  FutureOr<void> onCommandFinish(UserDefinedCommand command) {
    events.add('onCommandFinish(<<$command>>)');
  }

  @override
  FutureOr<void> onDialogueFinish() {
    events.add('onDialogueFinish()');
  }
}

class _InterruptingCow extends DialogueView {
  @override
  FutureOr<bool> onLineStart(DialogueLine line) async {
    dialogueRunner!.sendSignal("I'm a banana!");
    dialogueRunner!.stopLine();
    return false;
  }
}
