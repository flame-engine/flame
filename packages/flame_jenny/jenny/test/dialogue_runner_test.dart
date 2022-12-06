import 'dart:async';

import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import 'test_scenario.dart';
import 'utils.dart';

void main() {
  group('DialogueRunner', () {
    test('plain dialogue', () async {
      final yarn = YarnProject()
        ..parse(
          '-------------\n'
          'title: Hamlet\n'
          '-------------\n'
          "Bernardo:  Who's there?\n"
          'Francisco: Nay, answer me. Stand and unfold yourself.\n'
          'Bernardo:  Long live the King!\n'
          'Francisco: Bernardo?\n'
          'Bernardo:  He\n'
          'Francisco: You come most carefully upon your hour.\n'
          "Bernardo:  'Tis now struck twelve. Get thee to bed, Francisco.\n"
          "Francisco: For this relief much thanks. 'Tis bitter cold, "
          'And I am sick at heart.\n'
          '===\n',
        );
      final view = _RecordingDialogueView();
      final dialogue = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      await dialogue.runNode('Hamlet');
      expect(
        view.events,
        [
          // ignore_for_file: prefer_adjacent_string_concatenation
          '[*] onDialogueStart()',
          '[*] onNodeStart(Node(Hamlet))',
          "[*] onLineStart(DialogueLine(Bernardo: Who's there?))",
          "[*] onLineFinish(DialogueLine(Bernardo: Who's there?))",
          '[*] onLineStart(DialogueLine(Francisco: Nay, answer me. ' +
              'Stand and unfold yourself.))',
          '[*] onLineFinish(DialogueLine(Francisco: Nay, answer me. Stand ' +
              'and unfold yourself.))',
          '[*] onLineStart(DialogueLine(Bernardo: Long live the King!))',
          '[*] onLineFinish(DialogueLine(Bernardo: Long live the King!))',
          '[*] onLineStart(DialogueLine(Francisco: Bernardo?))',
          '[*] onLineFinish(DialogueLine(Francisco: Bernardo?))',
          '[*] onLineStart(DialogueLine(Bernardo: He))',
          '[*] onLineFinish(DialogueLine(Bernardo: He))',
          '[*] onLineStart(DialogueLine(Francisco: You come most carefully ' +
              'upon your hour.))',
          '[*] onLineFinish(DialogueLine(Francisco: You come most carefully ' +
              'upon your hour.))',
          "[*] onLineStart(DialogueLine(Bernardo: 'Tis now struck twelve. " +
              'Get thee to bed, Francisco.))',
          "[*] onLineFinish(DialogueLine(Bernardo: 'Tis now struck twelve. " +
              'Get thee to bed, Francisco.))',
          '[*] onLineStart(DialogueLine(Francisco: For this relief much ' +
              "thanks. 'Tis bitter cold, And I am sick at heart.))",
          '[*] onLineFinish(DialogueLine(Francisco: For this relief much ' +
              "thanks. 'Tis bitter cold, And I am sick at heart.))",
          '[*] onDialogueFinish()',
        ],
      );
    });

    test('DialogueViews with delays', () async {
      final yarn = YarnProject()
        ..parse('title: The Robot and the Mattress\n'
            '---\n'
            'Zem: Hello, robot\n'
            'Marvin: Blah\n'
            '===\n');
      final events = <String>[];
      final view1 = _DelayedDialogueView(
        target: events,
        name: 'A',
        dialogueStartDelay: 0.1,
        lineStartDelay: 0.1,
        lineFinishDelay: 0.02,
      );
      final view2 = _DelayedDialogueView(
        target: events,
        name: 'B',
        lineFinishDelay: 0.05,
      );
      final view3 = _DelayedDialogueView(
        target: events,
        name: 'C',
        dialogueStartDelay: 0.25,
        lineStartDelay: 0.15,
      );
      final dialogue = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2, view3],
      );
      await dialogue.runNode('The Robot and the Mattress');
      expect(events, [
        '[A] onDialogueStart()',
        '[B] onDialogueStart()',
        '[C] onDialogueStart()',
        '[A] onNodeStart(Node(The Robot and the Mattress))',
        '[B] onNodeStart(Node(The Robot and the Mattress))',
        '[C] onNodeStart(Node(The Robot and the Mattress))',
        '[A] onLineStart(DialogueLine(Zem: Hello, robot))',
        '[B] onLineStart(DialogueLine(Zem: Hello, robot))',
        '[C] onLineStart(DialogueLine(Zem: Hello, robot))',
        '[A] onLineFinish(DialogueLine(Zem: Hello, robot))',
        '[B] onLineFinish(DialogueLine(Zem: Hello, robot))',
        '[C] onLineFinish(DialogueLine(Zem: Hello, robot))',
        '[A] onLineStart(DialogueLine(Marvin: Blah))',
        '[B] onLineStart(DialogueLine(Marvin: Blah))',
        '[C] onLineStart(DialogueLine(Marvin: Blah))',
        '[A] onLineFinish(DialogueLine(Marvin: Blah))',
        '[B] onLineFinish(DialogueLine(Marvin: Blah))',
        '[C] onLineFinish(DialogueLine(Marvin: Blah))',
        '[A] onDialogueFinish()',
        '[B] onDialogueFinish()',
        '[C] onDialogueFinish()',
      ]);
    });

    test('dialogue with choices', () async {
      final yarn = YarnProject()
        ..parse('title: X\n---\n'
            '-> Hi there\n'
            '-> Howdy\n'
            '   Greetings to you too\n'
            '-> Yo! <<if false>>\n'
            'Kk-thx-bye\n'
            '===\n');
      final view = _RecordingDialogueView(choices: [1]);
      final dialogue = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      await dialogue.runNode('X');
      expect(
        view.events,
        [
          '[*] onDialogueStart()',
          '[*] onNodeStart(Node(X))',
          '[*] onChoiceStart(DialogueChoice([Option(Hi there), ' +
              'Option(Howdy), Option(Yo! #disabled)])) -> 1',
          '[*] onChoiceFinish(Option(Howdy))',
          '[*] onLineStart(DialogueLine(Greetings to you too))',
          '[*] onLineFinish(DialogueLine(Greetings to you too))',
          '[*] onLineStart(DialogueLine(Kk-thx-bye))',
          '[*] onLineFinish(DialogueLine(Kk-thx-bye))',
          '[*] onDialogueFinish()',
        ],
      );

      view.events.clear();
      view.choices.add(0);
      await dialogue.runNode('X');
      expect(
        view.events,
        [
          '[*] onDialogueStart()',
          '[*] onNodeStart(Node(X))',
          '[*] onChoiceStart(DialogueChoice([Option(Hi there), ' +
              'Option(Howdy), Option(Yo! #disabled)])) -> 0',
          '[*] onChoiceFinish(Option(Hi there))',
          '[*] onLineStart(DialogueLine(Kk-thx-bye))',
          '[*] onLineFinish(DialogueLine(Kk-thx-bye))',
          '[*] onDialogueFinish()',
        ],
      );
    });

    test('invalid dialogue choices', () async {
      final yarn = YarnProject()
        ..parse('title:A\n---\n'
            '-> Only one\n'
            '-> Only two <<if false>>\n'
            '===\n');
      final view = _RecordingDialogueView(choices: [2, 1]);
      final dialogue = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      await expectLater(
        () => dialogue.runNode('A'),
        hasDialogueError('Invalid option index chosen in a dialogue: 2'),
      );
      await expectLater(
        () => dialogue.runNode('A'),
        hasDialogueError(
          'A dialogue view selected a disabled option: '
          'Option(Only two #disabled)',
        ),
      );
    });

    test('no decision-making views', () {
      final yarn = YarnProject()..parse('title:A\n---\n-> One\n===\n');
      final dialogue = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [_SimpleDialogueView(), _SimpleDialogueView()],
      );
      expect(
        () => dialogue.runNode('A'),
        hasDialogueError(
          'No dialogue views capable of making a dialogue choice',
        ),
      );
    });

    testScenario(
      testName: 'Example.plan',
      input: '''
        title: Start
        tags: 
        colorID: 0
        position: 592,181
        ---
        A: Hey, I'm a character in a script!
        B: And I am too! You are talking to me!
        -> What's going on
            A: Why this is a demo of the script system!
            B: And you're in it!
        -> Um ok
        A: How delightful!
        B: What would you prefer to do next?
        -> Leave
            <<jump Leave>>
        -> Learn more
            <<jump LearnMore>>
        ===
        title: Leave
        tags: 
        colorID: 0
        position: 387,487
        ---
        A: Oh, goodbye!
        B: You'll be back soon!
        ===
        title: LearnMore
        tags: rawText
        colorID: 0
        position: 763,472
        ---
        A: HAHAHA
        ===''',
      testPlan: '''
        line: A: Hey, I'm a character in a script!
        line: B: And I am too! You are talking to me!
        option: What's going on    
        option: Um ok
        select: 1
        line: A: Why this is a demo of the script system!
        line: B: And you're in it!
        line: A: How delightful!
        line: B: What would you prefer to do next?
        option: Leave
        option: Learn more
        select: 1
        line: A: Oh, goodbye!
        line: B: You'll be back soon!
      ''',
    );

    testScenario(
      testName: 'Compiler.plan',
      input: r'''
        <<declare $foo as Number>>
        
        title: Start
        ---
        // Compiler tests
        This is a line!

        <<if false>>
          What what this is also a line!
        <<endif>>

        <<this is a custom command>>

        <<set $foo to 1+2>>

        <<if $foo is 3>>
          Foo is 3!
        <<elseif $foo is 4>>
          Foo is 4!
        <<else>>
          Foo is something TOTALLY DIFFERENT.
        <<endif>>

        -> This is a shortcut option that you'll never see <<if false>>
            Nice.
        -> This is a different shortcut option
            Sweet, but what about this?
            -> It's ok
                Cool.
            -> Huh?
        -> This is a shortcut option with no consequential text.

        All done with the shortcut options!
        ===
      ''',
      testPlan: '''
        line: This is a line!
        command: this is a custom command
        line: Foo is 3!
        option: This is a shortcut option that you'll never see [disabled]
        option: This is a different shortcut option
        option: This is a shortcut option with no consequential text.
        select: 2
        line: Sweet, but what about this?
        option: It's ok
        option: Huh?
        select: 1
        line: Cool.
        line: All done with the shortcut options!
      ''',
      commands: ['this'],
    );

    test('Dialogue runs node before finishing the previous one', () async {
      final yarn = YarnProject()
        ..parse(
          dedent('''
            title: Start
            ---
            First line
            Second line
            ===
            title: Other
            ---
            Third line
            ===
          '''),
        );
      final view = _RecordingDialogueView();
      final dialogue = DialogueRunner(yarnProject: yarn, dialogueViews: [view]);
      dialogue.runNode('Start');
      expect(
        () => dialogue.runNode('Other'),
        hasDialogueError(
          'Cannot run node "Other" because another node is currently running: '
          '"Start"',
        ),
      );
    });
  });
}

class _SimpleDialogueView extends DialogueView {}

class _RecordingDialogueView extends DialogueView {
  _RecordingDialogueView({
    List<String>? target,
    String? name,
    List<int>? choices,
  })  : events = target ?? [],
        name = name ?? '*',
        choices = choices ?? [];

  final List<String> events;
  final String name;
  final List<int> choices;

  @override
  void onDialogueStart() => _record('onDialogueStart()');

  @override
  void onDialogueFinish() => _record('onDialogueFinish()');

  @override
  void onNodeStart(Node node) => _record('onNodeStart($node)');

  @override
  FutureOr<bool> onLineStart(DialogueLine line) =>
      _record('onLineStart($line)');

  @override
  void onLineFinish(DialogueLine line) => _record('onLineFinish($line)');

  @override
  Future<int> onChoiceStart(DialogueChoice choice) {
    final selection = choices.isEmpty ? 0 : choices.removeAt(0);
    _record('onChoiceStart($choice) -> $selection');
    return Future<int>.value(selection);
  }

  @override
  void onChoiceFinish(DialogueOption option) =>
      _record('onChoiceFinish($option)');

  bool _record(String event) {
    events.add('[$name] $event');
    return true;
  }
}

class _DelayedDialogueView extends _RecordingDialogueView {
  _DelayedDialogueView({
    super.target,
    super.name,
    this.dialogueStartDelay = 0,
    this.lineStartDelay = 0,
    this.lineFinishDelay = 0,
  });

  final double dialogueStartDelay;
  final double lineStartDelay;
  final double lineFinishDelay;

  @override
  FutureOr<void> onDialogueStart() {
    super.onDialogueStart();
    if (dialogueStartDelay > 0) {
      final delay = Duration(milliseconds: (dialogueStartDelay * 1000).toInt());
      return Future.delayed(delay, () => null);
    }
  }

  @override
  Future<bool> onLineStart(DialogueLine line) {
    super.onLineStart(line);
    final delay = Duration(milliseconds: (lineStartDelay * 1000).toInt());
    return Future<bool>.delayed(delay, () => true);
  }

  @override
  Future<void> onLineFinish(DialogueLine line) {
    super.onLineFinish(line);
    final delay = Duration(milliseconds: (lineFinishDelay * 1000).toInt());
    return Future.delayed(delay);
  }
}
