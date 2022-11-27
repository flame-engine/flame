import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('NotEquals', () {
    test('x != y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { false != true }
          { 7 != 2 }
          { "m" + "on" + "key" != "monkey" }
          ===
        ''',
        testPlan: '''
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
            '{"flame" != 7}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: inequality operator between operands of unrelated types '
          'string and numeric\n'
          '>  at line 3 column 10:\n'
          '>  {"flame" != 7}\n'
          '>           ^\n',
        ),
      );
    });
  });
}
