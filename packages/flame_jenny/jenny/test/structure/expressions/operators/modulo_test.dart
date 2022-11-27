import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Modulo', () {
    test('x % y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 48 % 5 }
          { 4 % 1.2 }
          { -7 % 5 }
          { -3.14 % 1.5 }
          ===
        ''',
        testPlan: '''
          line: 3
          line: 0.40000000000000013
          line: 3
          line: 1.3599999999999999
        ''',
      );
    });

    test('x %= y', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $x = 10>>
          <<set $x %= 7>>
          { $x }
          ===
        ''',
        testPlan: '''
          line: 3
        ''',
      );
    });

    test('negative divisor', () {
      final yarn = YarnProject()
        ..parse(
          'title:A\n---\n'
          '{ 4 % -5 }\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;
      expect(
        line.evaluate,
        hasDialogueError(
          'The divisor of a modulo is not a positive number: -5',
        ),
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"X" % "y"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `%` must be numeric, '
          'instead the types are (string, string)\n'
          '>  at line 3 column 6:\n'
          '>  {"X" % "y"}\n'
          '>       ^\n',
        ),
      );
    });
  });
}
