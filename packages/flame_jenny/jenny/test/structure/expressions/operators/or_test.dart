import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Or', () {
    test('x || y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {true || true}
          {true || false}
          {false || true}
          {false || false}
          {true or true}
          {true or false}
          {false or true}
          {false or false}
          ===
        ''',
        testPlan: '''
          line: true
          line: true
          line: true
          line: false
          line: true
          line: true
          line: true
          line: false
        ''',
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{true || "false"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `||` must be boolean, '
          'instead the types are (boolean, string)\n'
          '>  at line 3 column 7:\n'
          '>  {true || "false"}\n'
          '>        ^\n',
        ),
      );
    });
  });
}
