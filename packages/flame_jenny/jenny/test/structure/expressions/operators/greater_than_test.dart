import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('GreaterThan', () {
    test('x > y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 7 > 5 + 1 }
          { 2.3 + 1 > 4 }
          ===
        ''',
        testPlan: '''
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
            '{true > false}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `>` must be numeric, '
          'instead the types are (boolean, boolean)\n'
          '>  at line 3 column 7:\n'
          '>  {true > false}\n'
          '>        ^\n',
        ),
      );
    });
  });
}
