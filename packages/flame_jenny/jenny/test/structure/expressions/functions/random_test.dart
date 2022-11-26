import 'dart:math';

import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('RandomFn', () {
    test('normal case', () async {
      await testScenario(
        yarn: YarnProject()..random = Random(42),
        input: '''
          title: Start
          ---
          Roll 1: {random()}
          Roll 2: {random()}
          Roll 3: {random()}
          ===
        ''',
        testPlan: '''
          line: Roll 1: 0.15092545597797424
          line: Roll 2: 0.6041479725361217
          line: Roll 3: 0.6616810157870647
        ''',
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{random(3, 0)}\n===\n'),
        hasTypeError(
          'TypeError: function random() requires no arguments\n'
          '>  at line 3 column 9:\n'
          '>  {random(3, 0)}\n'
          '>          ^\n',
        ),
      );
    });
  });
}
