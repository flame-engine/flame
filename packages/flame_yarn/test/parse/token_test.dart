import 'package:flame_yarn/src/parse/token.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('tokens without args', () {
      expect('${Token.asType}', 'Token.asType');
      expect('${Token.colon}', 'Token.colon');
      expect('${Token.endIndent}', 'Token.endIndent');
      expect('${Token.commandEndif}', 'Token.commandEndif');
      expect('${Token.constTrue}', 'Token.constTrue');
      expect('${Token.startExpression}', 'Token.startExpression');
      expect('${Token.opMinusAssign}', 'Token.opMinusAssign');
      expect('${Token.opXor}', 'Token.opXor');
      expect('${Token.typeString}', 'Token.typeString');
    });

    test('Token.text', () {
      const token = Token.text('some text');
      expect('$token', "Token.text('some text')");
      expect(token.type, TokenType.text);
      expect(token.content, 'some text');
    });

    test('Token.number', () {
      const token = Token.number('3.14159');
      expect('$token', "Token.number('3.14159')");
      expect(token.type, TokenType.number);
      expect(token.content, '3.14159');
    });

    test('Token.id', () {
      const token = Token.id('xyz127');
      expect('$token', "Token.id('xyz127')");
      expect(token.type, TokenType.id);
      expect(token.content, 'xyz127');
    });

    test('Token.variable', () {
      const token = Token.variable('flame');
      expect('$token', "Token.variable('flame')");
      expect(token.type, TokenType.variable);
      expect(token.content, 'flame');
    });

    test('Token.speaker', () {
      const token = Token.speaker('Mr_Obama');
      expect('$token', "Token.speaker('Mr_Obama')");
      expect(token.type, TokenType.speaker);
      expect(token.content, 'Mr_Obama');
    });

    test('Token.command', () {
      const token = Token.command('else');
      expect('$token', "Token.command('else')");
      expect(token.type, TokenType.command);
      expect(token.content, 'else');
    });

    test('equality', () {
      expect(Token.startParen == Token.startParen, true);
      expect(Token.startParen == Token.endParen, false);
      expect(const Token.text('foo') == const Token.text('foo'), true);
      expect(const Token.text('foo') == const Token.string('foo'), false);
      expect(const Token.text('foo') == const Token.text('bar'), false);

      expect(Token.arrow.hashCode == Token.comma.hashCode, false);
    });
  });
}
