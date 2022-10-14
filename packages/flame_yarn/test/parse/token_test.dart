import 'package:flame_yarn/src/parse/token.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('tokens without args', () {
      expect('${Token.as}', 'Token.as');
      expect('${Token.dedent}', 'Token.dedent');
      expect('${Token.commandEndif}', 'Token.commandEndif');
      expect('${Token.constTrue}', 'Token.constTrue');
      expect('${Token.expressionStart}', 'Token.expressionStart');
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
  });
}
