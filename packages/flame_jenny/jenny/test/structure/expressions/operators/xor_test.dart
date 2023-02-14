import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Xor', () {
    test('x ^ y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {true ^ true}
          {true ^ false}
          {false ^ true}
          {false ^ false}
          {true xor true}
          {true xor false}
          {false xor true}
          {false xor false}
          ===
        ''',
        testPlan: '''
          line: false
          line: true
          line: true
          line: false
          line: false
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
            '{"false" ^ "true"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `^` must be boolean, '
          'instead the types are (string, string)\n'
          '>  at line 3 column 10:\n'
          '>  {"false" ^ "true"}\n'
          '>           ^\n',
        ),
      );
    });
  });
}
