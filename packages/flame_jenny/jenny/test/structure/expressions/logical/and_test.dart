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
          {true && true}
          {true && false}
          {false && true}
          {false && false}
          ===
        ''',
        testPlan: '''
          line: true
          line: false
          line: false
          line: false
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
