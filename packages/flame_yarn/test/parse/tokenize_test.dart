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

      test('only header separator', () {
        expect(
          () => tokenize('---\n'),
          hasSyntaxError('SyntaxError: incomplete node body\n'
              '>  at line 2 column 1:\n'
              '>  \n'
              '>  ^\n'),
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
              '>  at line 1 column 3:\n'
              '>    title: this\n'
              '>    ^\n'),
        );
      });

      test('without id', () {
        expect(
          () => tokenize(':\n---\n===\n'),
          hasSyntaxError('SyntaxError: invalid token\n'
              '>  at line 1 column 1:\n'
              '>  :\n'
              '>  ^\n'),
        );
      });

      test('overlong separator', () {
        expect(
          () => tokenize('----\n===\n'),
          hasSyntaxError('SyntaxError: invalid token\n'
              '>  at line 1 column 1:\n'
              '>  ----\n'
              '>  ^\n'),
        );
      });
    });

    group('modeNodeBody', () {
      test('without final newline', () {
        expect(
          tokenize('---\n==='),
          const [Token.headerEnd, Token.bodyEnd],
        );
      });

      test('whitespace in body', () {
        expect(
          tokenize('---\n'
              '\n'
              '   \t  \r\n'
              ' // also could be some comments here\n'
              '==='),
          const [Token.headerEnd, Token.bodyEnd],
        );
      });

      test('indentation', () {
        expect(
          tokenize('---\n'
              '  alpha\n'
              '   beta\n'
              '\t     gamma\n'
              '  delta\n'
              '===\n'),
          const [
            Token.headerEnd,
            Token.indent,
            Token.text('alpha'),
            Token.newline,
            Token.indent,
            Token.text('beta'),
            Token.newline,
            Token.indent,
            Token.text('gamma'),
            Token.newline,
            Token.dedent,
            Token.dedent,
            Token.text('delta'),
            Token.newline,
            Token.dedent,
            Token.bodyEnd,
          ],
        );
      });

      test('invalid indentation', () {
        expect(
          () => tokenize('---\n'
              ' alpha\n'
              '     beta\n'
              '  gamma\n'
              '===\n'),
          hasSyntaxError('SyntaxError: inconsistent indentation\n'
              '>  at line 4 column 3:\n'
              '>    gamma\n'
              '>    ^\n'),
        );
      });

      test('dedents at end of body', () {
        expect(
          tokenize('---\n'
              'one\n'
              '  two\n'
              '    three\n'
              '==='),
          const [
            Token.headerEnd,
            Token.text('one'),
            Token.newline,
            Token.indent,
            Token.text('two'),
            Token.newline,
            Token.indent,
            Token.text('three'),
            Token.newline,
            Token.dedent,
            Token.dedent,
            Token.bodyEnd,
          ],
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
