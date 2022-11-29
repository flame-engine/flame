import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/commands/wait_command.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('WaitCommand', () {
    test('tokenize <<wait>>', () {
      expect(
        tokenize('<<wait 3>>'),
        const [
          Token.startCommand,
          Token.commandWait,
          Token.startExpression,
          Token.number('3'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('normal command <<wait>>', () async {
      final t0 = DateTime.now().millisecondsSinceEpoch;
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $duration = 1.0>>
          before wait
          <<wait $duration>>
          after wait
          ===
        ''',
        testPlan: '''
          line: before wait
          line: after wait
        ''',
      );
      final t1 = DateTime.now().millisecondsSinceEpoch;
      final elapsedTimeMs = t1 - t0;
      expect(elapsedTimeMs >= 1000, true);
      expect(elapsedTimeMs < 1100, true);
    });

    test('wrong argument type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<wait "two seconds">>\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: <<wait>> command expects a numeric argument\n'
          '>  at line 3 column 8:\n'
          '>  <<wait "two seconds">>\n'
          '>         ^\n',
        ),
      );
    });

    test('wrong command syntax', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<wait 2 seconds>>\n'
            '===\n',
          ),
        hasSyntaxError(
          'SyntaxError: unexpected token\n'
          '>  at line 3 column 10:\n'
          '>  <<wait 2 seconds>>\n'
          '>           ^\n',
        ),
      );
    });

    test('negative duration', () {
      const command = WaitCommand(NumLiteral(-1.0));
      expect(command.name, 'wait');
      expect(
        () => command.execute(
          DialogueRunner(yarnProject: YarnProject(), dialogueViews: []),
        ),
        hasDialogueError('<<wait>> command with negative duration: -1.0'),
      );
    });
  });
}
