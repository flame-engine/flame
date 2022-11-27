import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Negate', () {
    test('unary minus', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $x = 42>>
          { -7 + 1 }
          { 2 * -7 }
          { -$x }
          { -(3 + 111) }
          { --5 }
          ===
        ''',
        testPlan: '''
          line: -6
          line: -14
          line: -42
          line: -114
          line: 5
        ''',
      );
    });

    test('unary minus with wrong type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{-"banana"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: unary minus can only be applied to numbers\n'
          '>  at line 3 column 3:\n'
          '>  {-"banana"}\n'
          '>    ^\n',
        ),
      );
    });
  });
}
