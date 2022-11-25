import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('NumberFn', () {
    test('number() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          {number(1)} {number(2.5)}
          {1 + number(2 + 2)}
          {number(true)}
          {number(false)}
          {number("1")}
          {number("123") - 1}
          {number("2e2")}
          {number("   2e-1  ")}
          ===
        ''',
        testPlan: '''
          line: 1 2.5
          line: 5
          line: 1
          line: 0
          line: 1
          line: 122
          line: 200.0
          line: 0.2
        ''',
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{number()}\n===\n'),
        hasTypeError(
          'TypeError: function number() requires a single argument\n'
              '>  at line 3 column 9:\n'
              '>  {number()}\n'
              '>          ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{number(3, 6)}\n===\n'),
        hasTypeError(
          'TypeError: function number() requires a single argument\n'
              '>  at line 3 column 12:\n'
              '>  {number(3, 6)}\n'
              '>             ^\n',
        ),
      );
    });
  });
}
