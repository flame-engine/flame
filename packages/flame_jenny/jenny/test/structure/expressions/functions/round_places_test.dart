import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('RoundPlacesFn', () {
    test('round_places() normal case', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          2 -> {round_places(2, 0)}, {round_places(2, 1)}, {round_places(2, 2)}
          2.3 -> {round_places(2.3, 0)}, {round_places(2.3, 1)}
          7.001 -> {round_places(7.001, 0)}, {round_places(7.001, 2)}
          1/7 -> {round_places(1/7, 3)}, {round_places(1/7, 5)}
          -1/7 -> {round_places(-1/7, 3)}, {round_places(-1/7, 5)}
          ===
        ''',
        testPlan: '''
          line: 2 -> 2.0, 2.0, 2.0
          line: 2.3 -> 2.0, 2.3
          line: 7.001 -> 7.0, 7.0
          line: 1/7 -> 0.143, 0.14286
          line: -1/7 -> -0.143, -0.14286
        ''',
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{round_places(1)}\n===\n'),
        hasTypeError(
          'TypeError: function round_places() requires two arguments\n'
          '>  at line 3 column 16:\n'
          '>  {round_places(1)}\n'
          '>                 ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{round_places(3, 6, 1, 7)}\n===\n'),
        hasTypeError(
          'TypeError: function round_places() requires two arguments\n'
          '>  at line 3 column 21:\n'
          '>  {round_places(3, 6, 1, 7)}\n'
          '>                      ^\n',
        ),
      );
    });

    test('first argument not numeric', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{round_places("one", 1)}\n===\n'),
        hasTypeError(
          'TypeError: first argument in round_places() should be numeric\n'
          '>  at line 3 column 15:\n'
          '>  {round_places("one", 1)}\n'
          '>                ^\n',
        ),
      );
    });

    test('second argument not numeric', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{round_places(3, "one")}\n===\n'),
        hasTypeError(
          'TypeError: second argument in round_places() should be numeric\n'
          '>  at line 3 column 18:\n'
          '>  {round_places(3, "one")}\n'
          '>                   ^\n',
        ),
      );
    });
  });
}
