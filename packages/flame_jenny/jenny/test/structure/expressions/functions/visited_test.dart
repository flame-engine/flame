import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('VisitedFn', () {
    test('visit Start', () async {
      final yarn = YarnProject();
      await testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          visited Start = {visited("Start")}
          <<if not visited("Start")>>
            jumping...
            <<jump Start>>
          <<endif>>
          ===
        ''',
        testPlan: '''
          line: visited Start = false
          line: jumping...
          line: visited Start = true
        ''',
      );
      expect(yarn.variables.getNumericValue('@Start'), 2);
    });

    test('Visited.yarn', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          entered start
          <<if visited("Start")>>
            we have visited Start before
          <<else>>
            we have not visited Start
            <<jump Start>>
          <<endif>>
          ===
        ''',
        testPlan: '''
          line: entered start
          line: we have not visited Start
          line: entered start
          line: we have visited Start before
        ''',
      );
    });

    test('visited() with an unknown node', () {
      final yarn = YarnProject()
        ..parse('title:A\n'
            '---\n'
            '{visited("Africa")}\n'
            '===\n');
      final line = yarn.nodes['A']!.lines.first as DialogueLine;
      expect(
        line.evaluate,
        hasDialogueError('Unknown node name "Africa"'),
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{visited()}\n===\n'),
        hasTypeError(
          'TypeError: function visited() requires a single argument\n'
          '>  at line 3 column 10:\n'
          '>  {visited()}\n'
          '>           ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{visited("Start", "Finish")}\n===\n'),
        hasTypeError(
          'TypeError: function visited() requires a single argument\n'
          '>  at line 3 column 19:\n'
          '>  {visited("Start", "Finish")}\n'
          '>                    ^\n',
        ),
      );
    });

    test('invalid argument type', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{visited(1)}\n===\n'),
        hasTypeError(
          'TypeError: the argument should be a string\n'
          '>  at line 3 column 10:\n'
          '>  {visited(1)}\n'
          '>           ^\n',
        ),
      );
    });
  });
}
