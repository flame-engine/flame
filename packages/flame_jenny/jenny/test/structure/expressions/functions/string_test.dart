import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('StringFn', () {
    test('string() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {string(2 + 2)}
          {string(true)}
          {string(false)}
          {string("Jenny")}
          ===
        ''',
        testPlan: '''
          line: 4
          line: true
          line: false
          line: Jenny
        ''',
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{string()}\n===\n'),
        hasTypeError(
          'TypeError: function string() requires a single argument\n'
          '>  at line 3 column 9:\n'
          '>  {string()}\n'
          '>          ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{string(3, 6)}\n===\n'),
        hasTypeError(
          'TypeError: function string() requires a single argument\n'
          '>  at line 3 column 12:\n'
          '>  {string(3, 6)}\n'
          '>             ^\n',
        ),
      );
    });
  });
}
