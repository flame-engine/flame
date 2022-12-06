import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/structure/commands/declare_command.dart';
import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  group('DeclareCommand', () {
    test('tokenize declare', () {
      expect(
        tokenize(r'<<declare $x = 3>>'),
        const [
          Token.startCommand,
          Token.commandDeclare,
          Token.startExpression,
          Token.variable(r'$x'),
          Token.operatorAssign,
          Token.number('3'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('tokenize declare with as', () {
      expect(
        tokenize(r'<<declare $x = true as Bool>>'),
        const [
          Token.startCommand,
          Token.commandDeclare,
          Token.startExpression,
          Token.variable(r'$x'),
          Token.operatorAssign,
          Token.constTrue,
          Token.asType,
          Token.typeBool,
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    test('declare command', () {
      const command = DeclareCommand();
      expect(command.name, 'declare');
      expect(
        () => command.execute(
          DialogueRunner(yarnProject: YarnProject(), dialogueViews: []),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('declare with value', () {
      final yarn = YarnProject()..parse(r'<<declare $x = 3>>');
      expect(yarn.variables.hasVariable(r'$x'), true);
      expect(yarn.variables.getVariableType(r'$x'), ExpressionType.numeric);
      expect(yarn.variables.getNumericValue(r'$x'), 3);
    });

    test('declare with type', () {
      final yarn = YarnProject()..parse(r'<<declare $y as String>>');
      expect(yarn.variables.hasVariable(r'$y'), true);
      expect(yarn.variables.getVariableType(r'$y'), ExpressionType.string);
      expect(yarn.variables.getStringValue(r'$y'), '');
    });

    test('declare with value and type', () {
      final yarn = YarnProject()..parse(r'<<declare $y = "Flame" as String>>');
      expect(yarn.variables.hasVariable(r'$y'), true);
      expect(yarn.variables.getVariableType(r'$y'), ExpressionType.string);
      expect(yarn.variables.getStringValue(r'$y'), 'Flame');
    });

    test('declare multiple variables', () {
      final yarn = YarnProject()
        ..parse(
          '<<declare \$u as Bool>>\n'
          '<<declare \$v as Number>>\n'
          '<<declare \$w as String>>\n'
          '<<declare \$x = true>>\n'
          '<<declare \$y = 123>>\n'
          '<<declare \$z = "zzz">>\n',
        );
      expect(yarn.variables.hasVariable(r'$u'), true);
      expect(yarn.variables.hasVariable(r'$v'), true);
      expect(yarn.variables.hasVariable(r'$w'), true);
      expect(yarn.variables.hasVariable(r'$x'), true);
      expect(yarn.variables.hasVariable(r'$y'), true);
      expect(yarn.variables.hasVariable(r'$z'), true);
      expect(yarn.variables.getVariableType(r'$u'), ExpressionType.boolean);
      expect(yarn.variables.getVariableType(r'$v'), ExpressionType.numeric);
      expect(yarn.variables.getVariableType(r'$w'), ExpressionType.string);
      expect(yarn.variables.getVariableType(r'$x'), ExpressionType.boolean);
      expect(yarn.variables.getVariableType(r'$y'), ExpressionType.numeric);
      expect(yarn.variables.getVariableType(r'$z'), ExpressionType.string);
      expect(yarn.variables.getBooleanValue(r'$u'), false);
      expect(yarn.variables.getNumericValue(r'$v'), 0);
      expect(yarn.variables.getStringValue(r'$w'), '');
      expect(yarn.variables.getBooleanValue(r'$x'), true);
      expect(yarn.variables.getNumericValue(r'$y'), 123);
      expect(yarn.variables.getStringValue(r'$z'), 'zzz');
    });

    test('declare with a comment', () {
      final yarn = YarnProject()
        ..parse('<<declare \$x as String>>  // oh rly?\n');
      expect(yarn.variables.hasVariable(r'$x'), true);
      expect(yarn.variables.getVariableType(r'$x'), ExpressionType.string);
    });

    group('errors', () {
      test('missing variable name', () {
        expect(
          () => YarnProject()..parse('<<declare foo>>'),
          hasSyntaxError('SyntaxError: variable name expected\n'
              '>  at line 1 column 11:\n'
              '>  <<declare foo>>\n'
              '>            ^\n'),
        );
      });

      test('no assignment', () {
        expect(
          () => YarnProject()..parse(r'<<declare $error>>'),
          hasSyntaxError('SyntaxError: expected `= value` or `as Type`\n'
              '>  at line 1 column 17:\n'
              '>  <<declare \$error>>\n'
              '>                  ^\n'),
        );
      });

      test('variable redeclaration', () {
        expect(
          () => YarnProject()
            ..parse('<<declare \$error = 0>>\n'
                '<<declare \$error = 1>>\n'),
          hasNameError(
            'NameError: variable \$error has already been declared\n'
            '>  at line 2 column 11:\n'
            '>  <<declare \$error = 1>>\n'
            '>            ^\n',
          ),
        );
      });

      test('no type keyword after as 1', () {
        expect(
          () => YarnProject()..parse('<<declare \$error as 1>>\n'),
          hasSyntaxError(
            'SyntaxError: a type is expected\n'
            '>  at line 1 column 21:\n'
            '>  <<declare \$error as 1>>\n'
            '>                      ^\n',
          ),
        );
      });

      test('no type keyword after as 2', () {
        expect(
          () => YarnProject()..parse('<<declare \$error = 0 as 1>>\n'),
          hasSyntaxError(
            'SyntaxError: a type is expected\n'
            '>  at line 1 column 25:\n'
            '>  <<declare \$error = 0 as 1>>\n'
            '>                          ^\n',
          ),
        );
      });

      test('incompatible type declaration', () {
        expect(
          () => YarnProject()..parse('<<declare \$error = 0 as Bool>>\n'),
          hasTypeError(
            'TypeError: the expression evaluates to numeric type\n'
            '>  at line 1 column 25:\n'
            '>  <<declare \$error = 0 as Bool>>\n'
            '>                          ^\n',
          ),
        );
      });

      test('declare inside a node', () {
        expect(
          () => YarnProject()
            ..parse(
              'title: error\n---\n'
              '<<declare \$x = 1>>\n'
              '===\n',
            ),
          hasSyntaxError(
            'SyntaxError: <<declare>> command cannot be used inside a node\n'
            '>  at line 3 column 1:\n'
            '>  <<declare \$x = 1>>\n'
            '>  ^\n',
          ),
        );
      });
    });
  });
}
