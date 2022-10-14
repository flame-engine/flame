import 'package:flame_yarn/flame_yarn.dart';
import 'package:flame_yarn/src/parse/token.dart';
import 'package:flame_yarn/src/parse/tokenize.dart';
import 'package:test/test.dart';

void main() {
  group('tokenize', () {
    // Tests are organized according to which lexing Mode they are checking

    group('modeMain', () {
      test('empty input', () {
        expect(tokenize(''), <Token>[]);
        expect(tokenize(' '), <Token>[]);
        expect(tokenize(' \t  \n'), <Token>[]);
        expect(tokenize('\r\n\n   '), <Token>[]);
      });

      test('comments only', () {
        expect(tokenize('// hello'), <Token>[]);
        expect(tokenize('// world\n\n'), <Token>[]);
        expect(
          tokenize('\n'
              '//--------------------\n'
              '// BOILER PLATE       \n'
              '//--------------------\n'
              '\n'),
          <Token>[],
        );
      });
    });

    group('modeNodeHeader', () {
      test('no header lines', () {
        expect(
          tokenize('---\n===\n'),
          [Token.headerEnd, Token.bodyEnd],
        );
      });

      test('simple header', () {
        expect(
            tokenize('\n'
                'title: node: 1\n'
                '\n'
                '---\n===\n'),
            const [
              Token.id('title'),
              Token.colon,
              Token.text('node: 1'),
              Token.newline,
              Token.headerEnd,
              Token.bodyEnd,
            ]);
      });

      test('multi-line header', () {
        expect(
          tokenize('\n'
              'title: Some Long title\n'
              'title : Another title\n'
              'some_other_keyword:1\n'
              '---\n===\n'),
          const [
            Token.id('title'),
            Token.colon,
            Token.text('Some Long title'),
            Token.newline,
            Token.id('title'),
            Token.colon,
            Token.text('Another title'),
            Token.newline,
            Token.id('some_other_keyword'),
            Token.colon,
            Token.text('1'),
            Token.newline,
            Token.headerEnd,
            Token.bodyEnd,
          ],
        );
      });

      test('empty continuation of header line', () {
        expect(
          tokenize('foo:\n---\n===\n'),
          const [
            Token.id('foo'),
            Token.colon,
            Token.text(''),
            Token.newline,
            Token.headerEnd,
            Token.bodyEnd,
          ],
        );
      });

      test('multiple colons', () {
        expect(tokenize('foo::bar\n---\n===\n'), const [
          Token.id('foo'),
          Token.colon,
          Token.colon,
          Token.text('bar'),
          Token.newline,
          Token.headerEnd,
          Token.bodyEnd,
        ]);
      });

      test('header lines with comments', () {
        expect(
          tokenize('\n'
              'one: // comment\n'
              'two: some data //comment 2\n'
              '---\n===\n'),
          const [
            Token.id('one'),
            Token.colon,
            Token.text(''),
            Token.newline,
            Token.id('two'),
            Token.colon,
            Token.text('some data '),
            Token.newline,
            Token.headerEnd,
            Token.bodyEnd,
          ],
        );
      });

      test('extra whitespace', () {
        expect(
          () => tokenize('  title: this\n---\n===\n'),
          hasSyntaxError('SyntaxError: unexpected indentation\n'
              '>  at line 1 column 2:\n'
              '>    title: this\n'
              '>    ^\n'),
        );
      });

      test('without id', () {
        expect(
          () => tokenize(':\n---\n===\n'),
          hasSyntaxError('SyntaxError: invalid syntax\n'
              '>  at line 1 column 0:\n'
              '>  :\n'
              '>  ^\n'),
        );
      });
    });
  });
}

Matcher hasSyntaxError(String message) {
  return throwsA(
    isA<SyntaxError>().having((e) => e.toString(), 'toString', message),
  );
}
