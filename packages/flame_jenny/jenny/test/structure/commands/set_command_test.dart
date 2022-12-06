import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('SetCommand', () {
    test('tokenize <<set>>', () {
      expect(
        tokenize(r'<<set $x = 3>>'),
        const [
          Token.startCommand,
          Token.commandSet,
          Token.startExpression,
          Token.variable(r'$x'),
          Token.operatorAssign,
          Token.number('3'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('AnalysisTest.plan', () async {
      await testScenario(
        input: r'''
          <<declare $foo = 0>> // used
          <<declare $bar = 0>> // written to but never read
          ---
          title: Start
          ---
          <<set $foo to 1>>
          <<set $bar to $foo>>
          {$foo} {$bar}
          ===
        ''',
        testPlan: 'line: 1 1',
      );
    });

    test('Basic.plan', () async {
      await testScenario(
        input: r'''
          <<declare $foo as Number>>
          ---
          title: Start
          ---
          whoa what here's some text
          <<set $foo to (1+3*3/9)-1>>

          <<if $foo is 1>> // testing a comment
              this should appear :)
              <<if 1 is 1>>
                  NESTED IF BLOCK WHA-A-AT
                  <<set $foo += 47 + 6>>
              <<endif>>
          <<else>>
              oh noooo it didn't work :(
          <<endif>>

          <<if $foo is 54>>
              haha nice now 'set' works even when deeply nested
          <<else>>
              aaargh :(
          <<endif>>
          ===
        ''',
        testPlan: '''
          line: whoa what here's some text
          line: this should appear :)
          line: NESTED IF BLOCK WHA-A-AT
          line: haha nice now 'set' works even when deeply nested
        ''',
      );
    });

    test('modifying assignments', () async {
      await testScenario(
        input: r'''
          <<declare $x = 0>>
          <<declare $s = 'Hello'>>
          ---
          title: Start
          ---
          <<set $x += 12>>
          $x = {$x}
          <<set $x *= 4>>
          $x = {$x}
          <<set $x /= 6>>
          $x = {$x}
          <<set $x %= 5>>
          $x = {$x}
          <<set $x -= 2>>
          $x = {$x}
          <<set $s += " world">>
          $s = '{$s}'
          ===
        ''',
        testPlan: r'''
          line: $x = 12
          line: $x = 48
          line: $x = 8.0
          line: $x = 3.0
          line: $x = 1.0
          line: $s = 'Hello world'
        ''',
      );
    });

    group('errors', () {
      test('no variable', () {
        expect(
          () => YarnProject()
            ..parse(
              'title: W\n'
              '---\n'
              '<<set>>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: variable expected\n'
            '>  at line 3 column 6:\n'
            '>  <<set>>\n'
            '>       ^\n',
          ),
        );
      });

      test('undeclared variable', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:E\n'
              '---\n'
              '<<set \$foo = 123>>\n'
              '===\n',
            ),
          hasNameError(
            'NameError: variable \$foo has not been declared\n'
            '>  at line 3 column 7:\n'
            '>  <<set \$foo = 123>>\n'
            '>        ^\n',
          ),
        );
      });

      test('no assignment', () {
        expect(
          () => YarnProject()
            ..parse(
              '<<declare \$x as Number>>\n'
              'title: X\n'
              '---\n'
              '<<set \$x as String>>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: an assignment operator is expected\n'
            '>  at line 4 column 10:\n'
            '>  <<set \$x as String>>\n'
            '>           ^\n',
          ),
        );
      });

      test('wrong type in assignment', () {
        expect(
          () => YarnProject()
            ..parse(
              '<<declare \$x as String>>\n'
              'title: A\n'
              '---\n'
              '<<set \$x = 12>>\n'
              '===\n',
            ),
          hasTypeError(
            r'TypeError: variable $x of type string cannot be assigned a '
            'value of type numeric\n'
            '>  at line 4 column 12:\n'
            '>  <<set \$x = 12>>\n'
            '>             ^\n',
          ),
        );
      });

      test('<<set>> at root level', () {
        expect(
          () => YarnProject()
            ..parse(
              '<<declare \$x as Number>>\n'
              '<<set \$x = 1>>\n',
            ),
          hasTypeError(
            'TypeError: command <<set>> is only allowed inside nodes\n'
            '>  at line 2 column 1:\n'
            '>  <<set \$x = 1>>\n'
            '>  ^\n',
          ),
        );
      });
    });
  });
}
