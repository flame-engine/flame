import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('LessOrEqual', () {
    test('x <= y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 7 <= 5 + 2 }
          { 2.3 + 1 <= 4 }
          { 4 <= 3 }
          { 4 <= 4.0 }
          { 4 <= 4.0001 }
          ===
        ''',
        testPlan: '''
          line: true
          line: true
          line: false
          line: true
          line: true
        ''',
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"He" <= "She"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `<=` must be numeric, '
          'instead the types are (string, string)\n'
          '>  at line 3 column 7:\n'
          '>  {"He" <= "She"}\n'
          '>        ^\n',
        ),
      );
    });
  });
}
