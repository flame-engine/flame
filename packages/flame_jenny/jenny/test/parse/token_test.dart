import 'package:jenny/src/parse/token.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('tokens without args', () {
      expect('${Token.asType}', 'Token.asType');
      expect('${Token.closeMarkupTag}', 'Token.closeMarkupTag');
      expect('${Token.colon}', 'Token.colon');
      expect('${Token.commandEndif}', 'Token.commandEndif');
      expect('${Token.commandLocal}', 'Token.commandLocal');
      expect('${Token.constTrue}', 'Token.constTrue');
      expect('${Token.endIndent}', 'Token.endIndent');
      expect('${Token.endMarkupTag}', 'Token.endMarkupTag');
      expect('${Token.operatorMinusAssign}', 'Token.operatorMinusAssign');
      expect('${Token.operatorXor}', 'Token.operatorXor');
      expect('${Token.startExpression}', 'Token.startExpression');
      expect('${Token.startMarkupTag}', 'Token.startMarkupTag');
      expect('${Token.typeString}', 'Token.typeString');

      expect(Token.comma.isText, false);
      expect(Token.comma.isId, false);
      expect(Token.comma.isVariable, false);
      expect(Token.comma.isNumber, false);
      expect(Token.comma.isPerson, false);
      expect(Token.comma.isCommand, false);
      expect(Token.comma.isString, false);
      expect(Token.comma.isHashtag, false);
    });

    test('Token.text', () {
      const token = Token.text('some text');
      expect('$token', "Token.text('some text')");
      expect(token.isText, true);
      expect(token.type, TokenType.text);
      expect(token.content, 'some text');
    });

    test('Token.number', () {
      const token = Token.number('3.14159');
      expect('$token', "Token.number('3.14159')");
      expect(token.isNumber, true);
      expect(token.type, TokenType.number);
      expect(token.content, '3.14159');
    });

    test('Token.id', () {
      const token = Token.id('xyz127');
      expect('$token', "Token.id('xyz127')");
      expect(token.isId, true);
      expect(token.type, TokenType.id);
      expect(token.content, 'xyz127');
    });

    test('Token.variable', () {
      const token = Token.variable('flame');
      expect('$token', "Token.variable('flame')");
      expect(token.isVariable, true);
      expect(token.type, TokenType.variable);
      expect(token.content, 'flame');
    });

    test('Token.person', () {
      const token = Token.person('Mr_Obama');
      expect('$token', "Token.person('Mr_Obama')");
      expect(token.isPerson, true);
      expect(token.type, TokenType.person);
      expect(token.content, 'Mr_Obama');
    });

    test('Token.command', () {
      const token = Token.command('go');
      expect('$token', "Token.command('go')");
      expect(token.isCommand, true);
      expect(token.type, TokenType.command);
      expect(token.content, 'go');
    });

    test('equality', () {
      expect(Token.startParenthesis == Token.startParenthesis, true);
      expect(Token.startParenthesis == Token.endParenthesis, false);
      expect(const Token.text('foo') == const Token.text('foo'), true);
      expect(const Token.text('foo') == const Token.string('foo'), false);
      expect(const Token.text('foo') == const Token.text('bar'), false);

      expect(Token.arrow.hashCode == Token.comma.hashCode, false);
    });
  });
}
