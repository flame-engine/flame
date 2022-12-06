import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/commands/local_command.dart';
import 'package:test/test.dart';

import '../../test_scenario.dart';
import '../../utils.dart';

void main() {
  group('CommandLocal', () {
    test('tokenize', () {
      expect(
        tokenize(
          '---\n---\n'
          '<<local \$x = 3>>\n'
          '===\n',
        ),
        const [
          Token.startHeader,
          Token.endHeader,
          Token.startBody,
          Token.startCommand,
          Token.commandLocal,
          Token.startExpression,
          Token.variable(r'$x'),
          Token.operatorAssign,
          Token.number('3'),
          Token.endExpression,
          Token.endCommand,
          Token.newline,
          Token.endBody,
        ],
      );
    });

    test('parse', () {
      final yarn = YarnProject()
        ..parse(
          'title: Start\n'
          '---\n'
          '<<local \$x = 3>>\n'
          '===\n',
        );
      final node = yarn.nodes['Start']!;
      expect(node.lines.length, 1);
      expect(node.lines[0], isA<LocalCommand>());
      expect(node.variables, isNotNull);

      final command = node.lines[0] as LocalCommand;
      expect(command.name, 'local');
      expect(command.variable, r'$x');
      expect(command.storage == yarn.variables, false);
      expect(command.storage == node.variables, true);

      expect(yarn.variables.hasVariable(r'$x'), false);
      expect(node.variables!.hasVariable(r'$x'), true);
    });

    testScenario(
      testName: 'simple local command',
      input: r'''
        title: Start
        ---
        <<local $i = 3>>
        Value of $i = {$i}
        <<set $i += 10>>
        Value of $i = {$i}
        ===
      ''',
      testPlan: r'''
        line: Value of $i = 3
        line: Value of $i = 13
      ''',
    );

    testScenario(
      testName: 'local command executed multiple times',
      input: r'''
        <<declare $counter = 0>>
        ---
        title: Start
        ---
        <<local $i = 5 - $counter>>
        Countdown ...{$i}
        
        <<set $counter += 1>>
        <<if $counter < 5>>
          <<jump Start>>
        <<else>>
          GO!
        <<endif>>
        ===
      ''',
      testPlan: '''
        line: Countdown ...5
        line: Countdown ...4
        line: Countdown ...3
        line: Countdown ...2
        line: Countdown ...1
        line: GO!
      ''',
    );

    testScenario(
      testName: 'local command visibility',
      input: r'''
        title: Start
        ---
        First line
        <<if false>>
          <<local $x = 137>>
        <<else>>
          Value of x is {$x}
          <<set $x += 5>>
        <<endif>>
        Now x = {$x}
        ===
      ''',
      testPlan: '''
        line: First line
        line: Value of x is 0
        line: Now x = 5
      ''',
    );

    group('errors', () {
      test('declare local variable twice', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n'
              '<<local \$x = 1>>\n'
              '<<local \$x = 2>>\n'
              '===\n',
            ),
          hasNameError(
            'NameError: redeclaration of local variable \$x\n'
            '>  at line 4 column 9:\n'
            '>  <<local \$x = 2>>\n'
            '>          ^\n',
          ),
        );
      });

      test('global and local with the same name', () {
        expect(
          () => YarnProject()
            ..parse(
              '<<declare \$x as Number>>\n'
              'title:A\n---\n'
              '<<local \$x = 1>>\n'
              '===\n',
            ),
          hasNameError(
            r'NameError: variable $x shadows a global variable with the same '
            'name\n'
            '>  at line 4 column 9:\n'
            '>  <<local \$x = 1>>\n'
            '>          ^\n',
          ),
        );
      });

      test('... as Type', () {
        expect(
          () => YarnProject()
            ..parse(
              'title:A\n---\n'
              '<<local \$x as String>>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: assignment operator is expected\n'
            '>  at line 3 column 12:\n'
            '>  <<local \$x as String>>\n'
            '>             ^\n',
          ),
        );
      });
    });
  });
}
