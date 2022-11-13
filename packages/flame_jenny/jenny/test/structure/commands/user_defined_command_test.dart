import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/commands/user_defined_command.dart';
import 'package:test/test.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/parse/token.dart';
import '../../test_scenario.dart';

void main() {
  group('UserDefinedCommand', () {
    test('tokenization', () {
      expect(
        tokenize('---\n---\n'
            '<<hello world {\$exclamation}>>\n'
            '==='),
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

    test('Parse simple dialogue command', () {
      final project = YarnProject()
        ..commands.addDialogueCommand('hello')
        ..parse('title: start\n---\n'
            '<<hello world {"A" + "B"}>>\n'
            '===');
      expect(project.nodes['start']!.lines.length, 1);
      expect(project.nodes['start']!.lines[0], isA<UserDefinedCommand>());
      final cmd = project.nodes['start']!.lines[0] as UserDefinedCommand;
      expect(cmd.name, 'hello');
      expect(cmd.argumentString.value, 'world AB');
    });

    test('Execute a live command', () {
      var x = 0;
      var y = '';
      final project = YarnProject()
        ..commands.addCommand2('hello', (int a, String b) {
          x = a;
          y = b;
        })
        ..parse('title: start\n---\n'
            '<<hello 3 world>>\n'
            '===');
      final runner = DialogueRunner(yarnProject: project, dialogueViews: []);
      expect(project.nodes['start']!.lines.length, 1);
      expect(project.nodes['start']!.lines[0], isA<UserDefinedCommand>());
      final cmd = project.nodes['start']!.lines[0] as UserDefinedCommand;
      expect(cmd.name, 'hello');
      cmd.execute(runner);
      expect(x, 3);
      expect(y, 'world');
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

        <<nulled>>

        <<orion>>

        <<andorian>>

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
        command: nulled
        command: orion
        command: andorian
        command: note
        command: isActive
        command: p
        command: hide Collision:GermOnPorch
      ''',
      skip: true,
    );
  });
}
