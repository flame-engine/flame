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

    test('<<jump>> invalid syntax', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<jump 1>>\n'
            '===\n',
          ),
        hasSyntaxError(
          'SyntaxError: an ID or an expression expected\n'
          '>  at line 3 column 8:\n'
          '>  <<jump 1>>\n'
          '>         ^\n',
        ),
      );
    });

    test('<<jump>> with non-string-valued argument', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<jump {1.5}>>\n'
            '===\n',
          ),
        hasTypeError(
          'TypeError: target of <<jump>> must be a string expression\n'
          '>  at line 3 column 9:\n'
          '>  <<jump {1.5}>>\n'
          '>          ^\n',
        ),
      );
    });

    test('<<jump>> with unknown destination', () async {
      final yarn = YarnProject()
        ..parse(
          'title:A\n'
          '---\n'
          '<<jump Up>>\n'
          '===\n',
        );
      expect(
        () => DialogueRunner(yarnProject: yarn, dialogueViews: []).runNode('A'),
        hasNameError('NameError: Node "Up" could not be found'),
      );
    });
  });
}
