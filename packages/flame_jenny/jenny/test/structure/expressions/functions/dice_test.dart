import 'dart:math';

import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/expressions/functions/dice.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('DiceFn', () {
    test('simple invocation', () async {
      await testScenario(
        yarn: YarnProject()..random = Random(420),
        input: '''
          title: Start
          ---
          Roll 1: {dice(6)}
          Roll 2: {dice(6)} {dice(6)}
          Roll 3: {dice(6)} {dice(6)} {dice(6)}
          Roll 4: {dice(6)} {dice(6)} {dice(6)} {dice(6)}
          ===
        ''',
        testPlan: '''
          line: Roll 1: 3
          line: Roll 2: 6 3
          line: Roll 3: 2 1 2
          line: Roll 4: 1 6 4 3
        ''',
      );
    });

    test('dice() with fractional value', () {
      final diceFn = DiceFn(
        const NumLiteral(3.14),
        YarnProject()..random = Random(12345),
      );
      expect(diceFn.value, 1);
      expect(diceFn.value, 1);
      expect(diceFn.value, 2);
      expect(diceFn.value, 3);
    });

    test('dice(0)', () async {
      final diceFn = DiceFn(const NumLiteral(0), YarnProject());
      expect(
        () => diceFn.value,
        hasDialogueError('Argument to dice() must be positive: 0'),
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{dice()}\n===\n'),
        hasTypeError(
          'TypeError: function dice() requires a single argument\n'
          '>  at line 3 column 7:\n'
          '>  {dice()}\n'
          '>        ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{dice(3, 6)}\n===\n'),
        hasTypeError(
          'TypeError: function dice() requires a single argument\n'
          '>  at line 3 column 10:\n'
          '>  {dice(3, 6)}\n'
          '>           ^\n',
        ),
      );
    });

    test('invalid argument type', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{dice("three")}\n===\n'),
        hasTypeError(
          'TypeError: the argument should be numeric\n'
          '>  at line 3 column 7:\n'
          '>  {dice("three")}\n'
          '>        ^\n',
        ),
      );
    });
  });
}
