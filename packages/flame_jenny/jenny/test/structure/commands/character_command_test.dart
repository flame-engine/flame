import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:jenny/src/yarn_project.dart';
import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  group('CharacterCommand', () {
    test('tokenize <<character>> command', () {
      expect(
        tokenize('<<character "Agent Smith" Smith AgSmith>>'),
        const [
          Token.startCommand,
          Token.commandCharacter,
          Token.startExpression,
          Token.string('Agent Smith'),
          Token.id('Smith'),
          Token.id('AgSmith'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

    group('errors', () {
      test('invalid syntax', () {
        expect(
          () => YarnProject()..parse(r'<<character "Me" = $foo>>'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 1 column 18:\n'
              '>  <<character "Me" = \$foo>>\n'
              '>                   ^\n'),
        );
      });

      test('no character name or ids', () {
        expect(
          () => YarnProject()..parse('<<character>>'),
          hasSyntaxError('SyntaxError: at least one character id is required\n'
              '>  at line 1 column 12:\n'
              '>  <<character>>\n'
              '>             ^\n'),
        );
      });

      test('only character name', () {
        expect(
          () => YarnProject()..parse('<<character "Bozo">>'),
          hasSyntaxError('SyntaxError: at least one character id is required\n'
              '>  at line 1 column 19:\n'
              '>  <<character "Bozo">>\n'
              '>                    ^\n'),
        );
      });
    });
  });
}
