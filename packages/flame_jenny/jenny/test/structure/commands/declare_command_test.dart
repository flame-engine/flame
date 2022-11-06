import 'package:jenny/jenny.dart';
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

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

    test('declare an integer', () {
      final yarn = YarnProject()..parse(r'<<declare $x = 3>>');
      print(yarn);
    });
  });
}
