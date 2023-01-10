import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('if()', () {
    test('if() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { if(true, 17, -1) }
          { if(false, 17, -1) }
          { if(true, false, true) }
          { if(true, "orange", "magenta") }
          { if(false, "orange", "magenta") }
          ===
        ''',
        testPlan: '''
          line: 17
          line: -1
          line: false
          line: orange
          line: magenta
        ''',
      );
    });

    test('then/else evaluate only if necessary', () async {
      var invocationCount = 0;
      num t() => invocationCount++;

      await testScenario(
        yarn: YarnProject()..functions.addFunction0('t', t),
        input: '''
          title: Start
          ---
          { if(true, t() + 1, t() + 5) }
          { if(false, t() + 1, t() + 5) }
          ===
        ''',
        testPlan: '''
          line: 1
          line: 6
        ''',
      );
      expect(invocationCount, 2);
    });

    group('errors', () {
      test('too few arguments', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n{if(true, 1)}\n===\n',
            ),
          hasTypeError(
            'TypeError: function if() requires three arguments\n'
            '>  at line 3 column 12:\n'
            '>  {if(true, 1)}\n'
            '>             ^\n',
          ),
        );
      });

      test('too many arguments', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n{if(true, 1, 3, 6)}\n===\n',
            ),
          hasTypeError(
            'TypeError: function if() requires three arguments\n'
            '>  at line 3 column 17:\n'
            '>  {if(true, 1, 3, 6)}\n'
            '>                  ^\n',
          ),
        );
      });

      test('first argument is not boolean', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n{if(1, 3, 6)}\n===\n',
            ),
          hasTypeError(
            'TypeError: first argument in if() should be a boolean condition\n'
            '>  at line 3 column 5:\n'
            '>  {if(1, 3, 6)}\n'
            '>      ^\n',
          ),
        );
      });

      test('incompatible argument types', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n{if(true, 3, "no")}\n===\n',
            ),
          hasTypeError(
            'TypeError: the types of the second and the third arguments in '
            'if() must be the same, instead they were numeric and string\n'
            '>  at line 3 column 14:\n'
            '>  {if(true, 3, "no")}\n'
            '>               ^\n',
          ),
        );
      });
    });
  });
}
