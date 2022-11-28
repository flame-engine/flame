import 'package:jenny/jenny.dart';
import 'package:jenny/src/structure/block.dart';
import 'package:jenny/src/structure/commands/if_command.dart';
import 'package:jenny/src/structure/expressions/literal.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('IfCommand', () {
    test('command name', () {
      const command = IfCommand([IfBlock(constFalse, Block([]))]);
      expect(command.name, 'if');
    });

    testScenario(
      testName: 'IfStatements.yarn',
      input: '''
        title: Start
        ---
        <<if true>>
          Player: Hey, Sally. #line:794945
          Sally: Oh! Hi. #line:2dc39b
          Sally: You snuck up on me. #line:34de2f
          Sally: Don't do that. #line:dcc2bc
        <<else>>
          Player: Hey. #line:a8e70c
          Sally: Hi. #line:305cde
        <<endif>>
        ===
      ''',
      testPlan: '''
        line: Player: Hey, Sally.
        line: Sally: Oh! Hi.
        line: Sally: You snuck up on me.
        line: Sally: Don't do that.
      ''',
    );

    test('non-boolean condition in <<if>>', () {
      expect(
        () => YarnProject()
          ..parse('title:A\n---\n'
              '<<if "true">>\n'
              '    text\n'
              '<<endif>>\n'
              '===\n'),
        hasTypeError(
            'TypeError: expression in an <<if>> command must be boolean\n'
            '>  at line 3 column 6:\n'
            '>  <<if "true">>\n'
            '>       ^\n'),
      );
    });

    test('<<else>> without an <<if>>', () {
      expect(
        () => YarnProject()
          ..parse(
            'title:A\n---\n'
            '<<else>>\n'
            '<<endif>>\n'
            '===\n',
          ),
        hasSyntaxError(
          'SyntaxError: this command is only allowed after an <<if>>\n'
          '>  at line 3 column 3:\n'
          '>  <<else>>\n'
          '>    ^\n',
        ),
      );
    });
  });
}
