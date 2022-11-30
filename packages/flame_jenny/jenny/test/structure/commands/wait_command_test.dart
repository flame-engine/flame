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
      final yarn = YarnProject();
      var t0 = 0;
      var t1 = 0;
      yarn.functions
        ..addFunction0('startTimer', () {
          t0 = DateTime.now().millisecondsSinceEpoch;
          return '';
        })
        ..addFunction0('finishTimer', () {
          t1 = DateTime.now().millisecondsSinceEpoch;
          return '';
        });
      await testScenario(
        yarn: yarn,
        input: r'''
          title: Start
          ---
          <<local $duration = 1.0>>
          before wait{startTimer()}
          <<wait $duration>>
          after wait{finishTimer()}
          ===
        ''',
        testPlan: '''
          line: before wait
          line: after wait
        ''',
      );
      final elapsedTimeMs = t1 - t0;
      expect(elapsedTimeMs, greaterThanOrEqualTo(1000));
      expect(elapsedTimeMs, lessThan(1100));
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
