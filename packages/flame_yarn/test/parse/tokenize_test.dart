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
          [Token.bodyStart, Token.bodyEnd],
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
              Token.bodyStart,
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
            Token.bodyStart,
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
            Token.bodyStart,
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
          Token.bodyStart,
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
            Token.bodyStart,
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
          const [Token.bodyStart, Token.bodyEnd],
        );
      });

      test('whitespace in body', () {
        expect(
          tokenize('---\n'
              '\n'
              '   \t  \r\n'
              ' // also could be some comments here\n'
              '==='),
          const [Token.bodyStart, Token.bodyEnd],
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
            Token.bodyStart,
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
            Token.bodyStart,
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

      test('invalid body end', () {
        expect(
          () => tokenize('---\n===='),
          hasSyntaxError('SyntaxError: incomplete node body\n'
              '>  at line 2 column 5:\n'
              '>  ====\n'
              '>      ^\n'),
        );
      });
    });

    group('modeNodeBodyLine', () {
      test('option lines', () {
        expect(
          tokenize('---\n'
              '->something\n'
              '  -> other\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.arrow,
            Token.text('something'),
            Token.newline,
            Token.indent,
            Token.arrow,
            Token.text('other'),
            Token.newline,
            Token.dedent,
            Token.bodyEnd,
          ],
        );
      });

      test('commands', () {
        expect(
          tokenize('---\n'
              '<< >>\n'
              '<< stop >>\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.commandStart,
            Token.commandEnd,
            Token.newline,
            Token.commandStart,
            Token.commandStop,
            Token.commandEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('line speakers', () {
        expect(
          tokenize('---\n'
              'Marge: Hello!\n'
              'Mr Smith: You too\n'
              'ПанГолова :...\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.speaker('Marge'),
            Token.colon,
            Token.text('Hello!'),
            Token.newline,
            Token.text('Mr Smith: You too'),
            Token.newline,
            Token.speaker('ПанГолова'),
            Token.colon,
            Token.text('...'),
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('repeated arrow', () {
        expect(
          tokenize('---\n'
              '-> -> -> \n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.arrow,
            Token.arrow,
            Token.arrow,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('repeated character name', () {
        expect(
          tokenize('---\n'
              'Pig: Horse: Moo!\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.speaker('Pig'),
            Token.colon,
            Token.text('Horse: Moo!'),
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });
    });

    group('modeText', () {
      test('text with comment', () {
        expect(
          tokenize('---\n'
              'some text // here be dragons\n'
              'other text\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.text('some text '),
            Token.newline,
            Token.text('other text'),
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('escape sequences', () {
        expect(
          tokenize('---\n'
              r'\<\{ inside \}\>'
              '\n'
              'very long \\\n'
              '  text\n'
              'line with a newline:\\n ok\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.text('<'),
            Token.text('{'),
            Token.text(' inside '),
            Token.text('}'),
            Token.text('>'),
            Token.newline,
            Token.text('very long '),
            Token.text('text'),
            Token.newline,
            Token.text('line with a newline:'),
            Token.text('\n'),
            Token.text(' ok'),
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('invalid escape sequence', () {
        expect(
          () => tokenize('---\n'
              'some text \\a\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid escape sequence\n'
              '>  at line 2 column 12:\n'
              '>  some text \\a\n'
              '>             ^\n'),
        );
      });

      test('expressions', () {
        expect(
          tokenize('---\n'
              '{ } // noop\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.expressionStart,
            Token.expressionEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });
    });

    group('modeExpression', () {
      test('expression with assorted tokens', () {
        expect(
          tokenize('---\n'
              '{ \$x += 33 - 7/random() }\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.expressionStart,
            Token.variable('x'),
            Token.opPlusAssign,
            Token.number('33'),
            Token.opMinus,
            Token.number('7'),
            Token.opDivide,
            Token.id('random'),
            Token.parenStart,
            Token.parenEnd,
            Token.expressionEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('expression with keywords', () {
        expect(
          tokenize('---\n'
              '{ true * false as string }\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.expressionStart,
            Token.constTrue,
            Token.opMultiply,
            Token.constFalse,
            Token.as,
            Token.typeString,
            Token.expressionEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('expression with strings', () {
        expect(
          tokenize('---\n'
              '{ \$x = "hello" + ", world" }\n'
              '{ "one\' two", \'"\' }\n'
              '{ "last \\\' \\" \\\\ one\\n" }\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.expressionStart,
            Token.variable('x'),
            Token.opAssign,
            Token.string('hello'),
            Token.opPlus,
            Token.string(', world'),
            Token.expressionEnd,
            Token.newline,
            Token.expressionStart,
            Token.string("one' two"),
            Token.comma,
            Token.string('"'),
            Token.expressionEnd,
            Token.newline,
            Token.expressionStart,
            Token.string('last \' " \\ one\n'),
            Token.expressionEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('close command within a plain text expression', () {
        expect(
          tokenize('---\n'
              '{ a >> b }\n'
              '===\n'),
          const [
            Token.bodyStart,
            Token.expressionStart,
            Token.id('a'),
            Token.opGt,
            Token.opGt,
            Token.id('b'),
            Token.expressionEnd,
            Token.newline,
            Token.bodyEnd,
          ],
        );
      });

      test('invalid variable name', () {
        expect(
          () => tokenize('---\n'
              '{ \$a = \$7b }\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid variable name\n'
              '>  at line 2 column 8:\n'
              '>  { \$a = \$7b }\n'
              '>         ^\n'),
        );
      });

      test('invalid string', () {
        expect(
          () => tokenize('---\n'
              '{ "starting... }\n'
              '===\n'),
          hasSyntaxError(
              'SyntaxError: unexpected end of line while parsing a string\n'
              '>  at line 2 column 17:\n'
              '>  { "starting... }\n'
              '>                  ^\n'),
        );
      });
    });

    // group('modeCommand', () {
    //   test('incomplete command', () {
    //     expect(
    //       () => tokenize('---\n'
    //           '<< stop\n'
    //           '===\n'
    //       ),
    //       hasSyntaxError('SyntaxError: missing command close token ">>"\n'
    //         '>  at line 2 column 10:\n'
    //         '>  <<set a = b > 3 >\n'
    //         '>           ^\n'),
    //     );
    //   });
    // });
  });
}

Matcher hasSyntaxError(String message) {
  return throwsA(
    isA<SyntaxError>().having((e) => e.toString(), 'toString', message),
  );
}
