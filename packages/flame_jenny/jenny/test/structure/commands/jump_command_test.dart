import 'package:jenny/jenny.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('JumpCommand', () {
    test('Jumps.yarn', () async {
      await testScenario(
        input: r'''
          title: Start
          ---
          Start
          // Jump to a node name
          <<jump NodeNameDestination>>
          Error! This line should not be seen.
          ===
          title: NodeNameDestination
          ---
          NodeNameDestination
          // Jump to a node based on a constant expression
          <<jump {"NodeNameConstant" + "Expression"}>>
          ===
          title: NodeNameConstantExpression
          ---
          NodeNameExpression
          // Jump to a node based on a non-constant expression
          <<local $myNodeName = "NodeNameVariableExpression">>
          <<jump {$myNodeName}>>
          ===
          title: NodeNameVariableExpression
          ---
          NodeNameVariableExpression
          ===
        ''',
        testPlan: '''
          line: Start
          line: NodeNameDestination
          line: NodeNameExpression
          line: NodeNameVariableExpression
        ''',
      );
    });

    test('<<jump>> at root level', () {
      expect(
        () => YarnProject()..parse('<<jump Start>>\n'),
        hasTypeError(
          'TypeError: command <<jump>> is only allowed inside nodes\n'
          '>  at line 1 column 1:\n'
          '>  <<jump Start>>\n'
          '>  ^\n',
        ),
      );
    });
  });
}
