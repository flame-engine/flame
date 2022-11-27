import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Multiply', () {
    test('x * y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 11 * 8 * 0.5 }
          { 2 * -3 }
          ===
        ''',
        testPlan: '''
          line: 44.0
          line: -6
        ''',
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"X" * "zero"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `*` must be numeric, '
          'instead the types are (string, string)\n'
          '>  at line 3 column 6:\n'
          '>  {"X" * "zero"}\n'
          '>       ^\n',
        ),
      );
    });
  });
}
