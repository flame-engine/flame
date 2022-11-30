import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/commands/stop_command.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('StopCommand', () {
    test('tokenize <<stop>>', () {
      expect(
        tokenize('<<stop>>'),
        const [
          Token.startCommand,
          Token.commandStop,
          Token.endCommand,
        ],
      );
    });

    test('command name', () {
      const command = StopCommand();
      expect(command.name, 'stop');
    });

    test('normal command <<stop>>', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          before stop
          <<stop>>
          after stop
          ===
        ''',
        testPlan: '''
          line: before stop
        ''',
      );
    });

    test('invalid syntax for <<stop>>', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<stop 5>>\n'
            '===\n',
          ),
        hasSyntaxError(
          'SyntaxError: invalid token\n'
          '>  at line 3 column 8:\n'
          '>  <<stop 5>>\n'
          '>         ^\n',
        ),
      );
    });
  });
}
