import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('LessThan', () {
    test('x < y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 7 < 5 + 1 }
          { 2.3 + 1 < 4 }
          ===
        ''',
        testPlan: '''
          line: false
          line: true
        ''',
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"jenny" < 7}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `<` must be numeric, '
          'instead the types are (string, numeric)\n'
          '>  at line 3 column 10:\n'
          '>  {"jenny" < 7}\n'
          '>           ^\n',
        ),
      );
    });
  });
}
