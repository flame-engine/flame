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
          {string(12345678900000000000000000)}
          {string(0.000000001)}
          ===
        ''',
        testPlan: '''
          line: 4
          line: true
          line: false
          line: Jenny
          line: 1.23456789e+25
          line: 1e-9
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
