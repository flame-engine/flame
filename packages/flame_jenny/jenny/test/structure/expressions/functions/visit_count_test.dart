import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../../test_scenario.dart';
import '../../../utils.dart';

void main() {
  group('VisitCountFn', () {
    test('visit_count Start', () async {
      final yarn = YarnProject();
      await testScenario(
        yarn: yarn,
        input: '''
          title: Start
          ---
          count of Start visits = {visit_count("Start")}
          <<if not visited("Start")>>
            jumping...
            <<jump Start>>
          <<endif>>
          ===
        ''',
        testPlan: '''
          line: count of Start visits = 0
          line: jumping...
          line: count of Start visits = 1
        ''',
      );
      expect(yarn.variables.getNumericValue('@Start'), 2);
    });

    test('VisitCount.yarn', () async {
      await testScenario(
        input: '''
          title: Start
          ---
          entered start
          seconds visited count is {visit_count("second")} // default = 0
          <<jump second>>
          ===

          title: second
          ---
          <<if visit_count("second") < 3>>
            second visited {visit_count("second")} times // will be 0,1,2
            <<jump second>>
          <<else>>
            <<jump third>>
          <<endif>>
          ===

          title: third
          ---
          entered third
          seconds was visited a total of {visit_count("second")} times // 4
          ===
        ''',
        testPlan: '''
          line: entered start
          line: seconds visited count is 0
          line: second visited 0 times
          line: second visited 1 times
          line: second visited 2 times
          line: entered third
          line: seconds was visited a total of 4 times
        ''',
      );
    });

    test('VisitTracking.yarn', () async {
      // Note: we ignore the tracking directive and always track all nodes
      await testScenario(
        input: '''
          title: Start
          ---
          beginning
          <<jump NoTrack>>
          ===
          
          title: NoTrack
          tracking: never
          ---
          entered NoTrack
          <<jump Track>>
          ===
          
          title: Track
          tracking: always
          ---
          entered Track
          <<jump End>>
          ===
          
          title: End
          ---
          entered End
          did we visit NoTrack? {visited("NoTrack")}!
          did we visit Track? {visited("Trac" + "k")}!
          done
          ===
        ''',
        testPlan: '''
          line: beginning
          line: entered NoTrack
          line: entered Track
          line: entered End
          line: did we visit NoTrack? true!
          line: did we visit Track? true!
          line: done
        ''',
      );
    });

    test('visit_count() with an unknown node', () {
      final yarn = YarnProject()
        ..parse('title:A\n'
            '---\n'
            '{visit_count("Africa")}\n'
            '===\n');
      final line = yarn.nodes['A']!.lines.first as DialogueLine;
      expect(
        line.evaluate,
        hasDialogueError('Unknown node name "Africa"'),
      );
    });

    test('too few arguments', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{visit_count()}\n===\n'),
        hasTypeError(
          'TypeError: function visit_count() requires a single argument\n'
          '>  at line 3 column 14:\n'
          '>  {visit_count()}\n'
          '>               ^\n',
        ),
      );
    });

    test('too many arguments', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n{visit_count("Start", "Finish")}\n===\n'),
        hasTypeError(
          'TypeError: function visit_count() requires a single argument\n'
          '>  at line 3 column 23:\n'
          '>  {visit_count("Start", "Finish")}\n'
          '>                        ^\n',
        ),
      );
    });

    test('invalid argument type', () {
      expect(
        () => YarnProject()..parse('title:A\n---\n{visit_count(1)}\n===\n'),
        hasTypeError(
          'TypeError: the argument should be a string\n'
          '>  at line 3 column 14:\n'
          '>  {visit_count(1)}\n'
          '>               ^\n',
        ),
      );
    });
  });
}
