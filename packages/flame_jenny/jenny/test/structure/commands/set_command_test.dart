import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';

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

    testScenario(
      testName: 'AnalysisTest.plan',
      input: r'''
        <<declare $foo = 0>> // used
        <<declare $bar = 0>> // written to but never read

        title: Start
        ---
        // testing

        <<set $foo to 1>>
        <<set $bar to $foo>>
        {$foo} {$bar}
        ===
      ''',
      testPlan: 'line: 1 1',
    );

    testScenario(
      testName: 'Basic.plan',
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
                NESTED IF BLOCK WHAAAT
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
        line: NESTED IF BLOCK WHAAAT
        line: haha nice now 'set' works even when deeply nested
      ''',
    );
  });
}
