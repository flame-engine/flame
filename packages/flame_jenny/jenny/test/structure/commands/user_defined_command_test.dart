import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('UserDefinedCommand', () {
    test('tokenization', () {
      expect(
        tokenize(
          '---\n---\n'
          '<<hello world {\$exclamation}>>\n'
          '===',
        ),
        const [
          Token.startHeader,
          Token.endHeader,
          Token.startBody,
          Token.startCommand,
          Token.command('hello'),
          Token.text('world '),
          Token.startExpression,
          Token.variable(r'$exclamation'),
          Token.endExpression,
          Token.endCommand,
          Token.newline,
          Token.endBody,
        ],
      );
    });

    test('parse simple dialogue command', () {
      final project = YarnProject()
        ..commands.addOrphanedCommand('hello')
        ..parse(
          'title: start\n---\n'
          '<<hello world {"A" + "B"}>>\n'
          '===',
        );
      expect(project.nodes['start']!.lines.length, 1);
      expect(project.nodes['start']!.lines[0], isA<UserDefinedCommand>());
      final cmd = project.nodes['start']!.lines[0] as UserDefinedCommand;
      expect(cmd.name, 'hello');
      project.commands.runCommand(cmd);
      expect(cmd.argumentString, 'world AB');
    });

    test('execute a live command', () {
      var x = 0;
      var y = '';
      final project = YarnProject()
        ..commands.addCommand2('hello', (int a, String b) {
          x = a;
          y = b;
        })
        ..parse(
          'title: start\n---\n'
          '<<hello 3 world>>\n'
          '===',
        );
      final runner = DialogueRunner(yarnProject: project, dialogueViews: []);
      expect(project.nodes['start']!.lines.length, 1);
      expect(project.nodes['start']!.lines[0], isA<UserDefinedCommand>());
      final cmd = project.nodes['start']!.lines[0] as UserDefinedCommand;
      expect(cmd.name, 'hello');
      cmd.execute(runner);
      expect(x, 3);
      expect(y, 'world');
    });

    test('undeclared user-defined command', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n<<jenny>>\n===\n'),
        hasNameError(
          'NameError: Unknown user-defined command <<jenny>>\n'
          '>  at line 3 column 3:\n'
          '>  <<jenny>>\n'
          '>    ^\n',
        ),
      );
    });

    test('markup within user-defined command', () {
      expect(
        () => YarnProject()
          ..commands.addOrphanedCommand('hello')
          ..parse(
            'title:A\n---\n'
            '<<hello Big [bad/] Wolf>>\n'
            '===\n',
          ),
        hasSyntaxError(
          'SyntaxError: invalid token\n'
          '>  at line 3 column 13:\n'
          '>  <<hello Big [bad/] Wolf>>\n'
          '>              ^\n',
        ),
      );
    });

    test('evaluate a command multiple times', () async {
      var counter = 0;
      await testScenario(
        yarn: YarnProject()..functions.addFunction0('next', () => counter += 1),
        input: r'''
          <<declare $i = 0>> 
          title: Start
          ---
          <<print {$i} {next()}>>
          <<set $i += 1>>
          <<if $i < 5>>
            <<jump Start>>
          <<endif>>
          ===
        ''',
        testPlan: '''
          command: print 0 1
          command: print 1 2
          command: print 2 3
          command: print 3 4
          command: print 4 5
        ''',
        commands: ['print'],
      );
    });

    test('access command arguments', () async {
      var fnCounter = 0;
      final yarn = YarnProject()
        ..commands.addCommand3('xyz', (String p0, String p1, String p2) => null)
        ..functions.addFunction0('fn', () => fnCounter += 1)
        ..parse(
          dedent('''
            title: Start
            ---
            <<xyz a b {fn()}>>
            ===
            '''),
        );
      final view1 = _CommandDialogueView();
      final view2 = _CommandDialogueView();
      final dialogueRunner = DialogueRunner(
        yarnProject: yarn,
        dialogueViews: [view1, view2],
      );

      await dialogueRunner.startDialogue('Start');
      expect(fnCounter, 1);
      expect(view1.numCalled, 1);
      expect(view1.argumentString, 'a b 1');
      expect(view1.arguments, ['a', 'b', '1']);
      expect(view2.numCalled, 1);
      expect(view2.argumentString, 'a b 1');
      expect(view2.arguments, ['a', 'b', '1']);

      await dialogueRunner.startDialogue('Start');
      expect(fnCounter, 2);
      expect(view2.numCalled, 2);
      expect(view2.argumentString, 'a b 2');
      expect(view2.arguments, ['a', 'b', '2']);
    });

    testScenario(
      testName: 'Commands.yarn',
      input: '''
        title: Start
        ---
        // Testing commands
        <<flip Harley3 +1>>

        // Commands that begin with keywords
        <<toggle>>
        <<settings>>
        <<iffy>>
        <<nullify>>
        <<orion>>
        <<andromeda>>
        <<note>>
        <<isActive>>

        // Commands with a single character
        <<p>>

        // Commands with colons
        <<hide Collision:GermOnPorch>>
        ===
      ''',
      testPlan: '''
        command: flip Harley3 +1
        command: toggle
        command: settings
        command: iffy
        command: nullify
        command: orion
        command: andromeda
        command: note
        command: isActive
        command: p
        command: hide Collision:GermOnPorch
      ''',
      commands: [
        'flip',
        'toggle',
        'settings',
        'iffy',
        'nullify',
        'orion',
        'andromeda',
        'note',
        'isActive',
        'p',
        'hide',
      ],
    );
  });
}

class _CommandDialogueView extends DialogueView {
  int numCalled = 0;
  String argumentString = '';
  List<dynamic> arguments = <int>[];

  @override
  void onCommand(UserDefinedCommand command) {
    numCalled += 1;
    arguments = command.arguments!;
    argumentString = command.argumentString;
  }
}
