import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Not', () {
    test('not', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {! true} {! false}
          {not true} {not false}
          {! 5==5}
          {! (false || true)}
          ===
        ''',
        testPlan: '''
          line: false true
          line: false true
          line: false
          line: false
        ''',
      );
    });

    test('not with wrong type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{! 5}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: operator `not` can only be applied to booleans\n'
          '>  at line 3 column 4:\n'
          '>  {! 5}\n'
          '>     ^\n',
        ),
      );
    });
  });
}
