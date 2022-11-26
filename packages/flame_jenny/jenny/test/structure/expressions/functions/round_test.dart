import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('RoundFn', () {
    test('round() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2    -> {round(2)}
          2.3  -> {round(2.3)}
          2.5  -> {round(2.5)}
          2.99 -> {round(2.99)}
          -0.3 -> {round(-0.3)}
          ===
        ''',
        testPlan: '''
          line: 2    -> 2
          line: 2.3  -> 2
          line: 2.5  -> 3
          line: 2.99 -> 3
          line: -0.3 -> 0
        ''',
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{round()}\n===\n'),
        hasTypeError(
          'TypeError: function round() requires a single argument\n'
          '>  at line 3 column 8:\n'
          '>  {round()}\n'
          '>         ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{round(3, 0)}\n===\n'),
        hasTypeError(
          'TypeError: function round() requires a single argument\n'
          '>  at line 3 column 11:\n'
          '>  {round(3, 0)}\n'
          '>            ^\n',
        ),
      );
    });

    test('non-numeric argument', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{round("o")}\n===\n'),
        hasTypeError(
          'TypeError: the argument in round() should be numeric\n'
          '>  at line 3 column 8:\n'
          '>  {round("o")}\n'
          '>         ^\n',
        ),
      );
    });
  });
}
