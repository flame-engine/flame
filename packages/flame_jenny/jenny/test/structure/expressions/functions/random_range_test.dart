import 'dart:math';

import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/expressions/functions/random_range.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('RandomRangeFn', () {
    test('normal invocation', () async {
      await testScenario(
        yarn: YarnProject()..random = Random(7),
        input: '''
          title: Start
          ---
          1: {random_range(3, 6)}
          2: {random_range(-12, 12)}
          3: {random_range(0, 100)}
          4: {random_range(50, 70)}
          ===
        ''',
        testPlan: '''
          line: 1: 3
          line: 2: 0
          line: 3: 57
          line: 4: 59
        ''',
      );
    });

    test('random_range() stress test', () {
      final fn = RandomRangeFn(
        const NumLiteral(-20),
        const NumLiteral(20),
        YarnProject()..random = Random(12345),
      );
      num min = 1000;
      num max = -1000;
      for (var i = 0; i < 100; i++) {
        final value = fn.value;
        if (value < min) {
          min = value;
        }
        if (value > max) {
          max = value;
        }
      }
      expect(min, -20);
      expect(max, 20);
    });

    test('random range with min == max', () async {
      final fn = RandomRangeFn(
        const NumLiteral(0),
        const NumLiteral(0),
        YarnProject(),
      );
      expect(fn.value, 0);
    });

    test('random range with min > max', () async {
      final fn = RandomRangeFn(
        const NumLiteral(10),
        const NumLiteral(0),
        YarnProject(),
      );
      expect(
        () => fn.value,
        hasDialogueError(
          'In random_range(a=10, b=0) the upper bound cannot be less than the '
          'lower bound',
        ),
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{random_range(1)}\n===\n',
          ),
        hasTypeError(
          'TypeError: function random_range() requires two arguments\n'
          '>  at line 3 column 16:\n'
          '>  {random_range(1)}\n'
          '>                 ^\n',
        ),
      );
    });

    test('invalid argument 1 type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{random_range(true, 12)}\n===\n',
          ),
        hasTypeError(
          'TypeError: the first argument should be numeric\n'
          '>  at line 3 column 15:\n'
          '>  {random_range(true, 12)}\n'
          '>                ^\n',
        ),
      );
    });

    test('invalid argument 2 type', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n{random_range(3, "seventeen")}\n===\n',
          ),
        hasTypeError(
          'TypeError: the second argument should be numeric\n'
          '>  at line 3 column 18:\n'
          '>  {random_range(3, "seventeen")}\n'
          '>                   ^\n',
        ),
      );
    });
  });
}
