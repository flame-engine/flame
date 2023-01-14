
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

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

    });
  });
}
