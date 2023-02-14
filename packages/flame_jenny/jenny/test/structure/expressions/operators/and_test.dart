import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('And', () {
    test('x && y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {true && true} {true and true}
          {true && false} {true and false}
          {false && true} {false and true}
          {false && false} {false and false}
          ===
        ''',
        testPlan: '''
          line: true true
          line: false false
          line: false false
          line: false false
        ''',
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{true && 0}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `&&` must be boolean, '
          'instead the types are (boolean, numeric)\n'
          '>  at line 3 column 7:\n'
          '>  {true && 0}\n'
          '>        ^\n',
        ),
      );
    });
  });
}
