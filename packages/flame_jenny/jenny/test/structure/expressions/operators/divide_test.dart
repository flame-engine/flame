import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('Divide', () {
    test('x / y', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          { 48 / 2 / 3 }
          ===
        ''',
        testPlan: '''
          line: 8.0
        ''',
      );
    });

    test('x /= y', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          <<local $x = 8>>
          <<set $x /= 2>>
          {$x}
          ===
        ''',
        testPlan: '''
          line: 4.0
        ''',
      );
    });

    test('division by zero', () {
      final yarn = YarnProject()
        ..parse(
          'title:A\n---\n'
          '{ 4 / 0 }\n'
          '===\n',
        );
      final line = yarn.nodes['A']!.lines[0] as DialogueLine;
      expect(
        line.evaluate,
        hasDialogueError('Division by zero'),
      );
    });

    test('wrong argument types', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '{"X" / "y"}\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: both left and right sides of `/` must be numeric, '
          'instead the types are (string, string)\n'
          '>  at line 3 column 6:\n'
          '>  {"X" / "y"}\n'
          '>       ^\n',
        ),
      );
    });
  });
}
