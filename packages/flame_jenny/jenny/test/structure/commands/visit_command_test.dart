
import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

void main() {
  group('VisitCommand', () {
    test('tokenize bare-word node target', () {
      expect(
        tokenize('<<visit WhiteHouse>>'),
        const [
          Token.startCommand,
          Token.commandVisit,
          Token.id('WhiteHouse'),
          Token.endCommand,
        ],
      );
    });

    test('tokenize expression node target', () {
      expect(
        tokenize(r'<<visit {$destination}>>'),
        const [
          Token.startCommand,
          Token.commandVisit,
          Token.startExpression,
          Token.variable(r'$destination'),
          Token.endExpression,
          Token.endCommand,
        ],
      );
    });

  });
}
