import 'package:jenny/src/parse/token.dart';
import 'package:jenny/src/parse/tokenize.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  // Tests are organized according to which lexing Mode they are checking
  group('tokenize', () {
    group('modeMain', () {
      test('empty input', () {
        expect(tokenize(''), <Token>[]);
        expect(tokenize(' '), <Token>[]);
        expect(tokenize(' \t  \n'), [Token.newline]);
        expect(tokenize('\r\n\n   '), [Token.newline, Token.newline]);
      });

      test('comments only', () {
        expect(tokenize('// hello'), const <Token>[]);
        expect(tokenize('// world\n\n'), [Token.newline, Token.newline]);
        expect(
          tokenize('\n'
              '//--------------------\n'
              '// BOILER PLATE       \n'
              '//--------------------\n'
              '\n'),
          const [
            Token.newline,
            Token.newline,
            Token.newline,
            Token.newline,
            Token.newline,
          ],
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

      test('main-mode tags', () {
        expect(
          tokenize(
            '# version: 2.3\n'
            '#ok',
          ),
          const [
            Token.hashtag('# version: 2.3'),
            Token.newline,
            Token.hashtag('#ok'),
            Token.newline,
          ],
        );
      });

      test('main-mode commands', () {
        expect(
          tokenize('<<stop>>\n'),
          [
            Token.startCommand,
            Token.commandStop,
            Token.endCommand,
            Token.newline,
          ],
        );
      });
    });

    group('modeNodeHeader', () {
      test('no header lines', () {
        expect(
          tokenize('---\n---\n===\n'),
          [Token.startHeader, Token.endHeader, Token.startBody, Token.endBody],
        );
      });

      test('simple header', () {
        expect(
            tokenize('\n'
                'title: node: 1\n'
                '\n'
                '---\n===\n'),
            const [
              Token.newline,
              Token.startHeader,
              Token.id('title'),
              Token.colon,
              Token.text('node: 1'),
              Token.newline,
              Token.newline,
              Token.endHeader,
              Token.startBody,
              Token.endBody,
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
            Token.newline,
            Token.startHeader,
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
            Token.endHeader,
            Token.startBody,
            Token.endBody,
          ],
        );
      });

      test('empty continuation of header line', () {
        expect(
          tokenize('foo:\n---\n===\n'),
          const [
            Token.startHeader,
            Token.id('foo'),
            Token.colon,
            Token.text(''),
            Token.newline,
            Token.endHeader,
            Token.startBody,
            Token.endBody,
          ],
        );
      });

      test('multiple colons', () {
        expect(tokenize('foo::bar\n---\n===\n'), const [
          Token.startHeader,
          Token.id('foo'),
          Token.colon,
          Token.colon,
          Token.text('bar'),
          Token.newline,
          Token.endHeader,
          Token.startBody,
          Token.endBody,
        ]);
      });

      test('header lines with comments', () {
        expect(
          tokenize(
            'one: // comment\n'
            '\n'
            'two: some data //comment 2\n'
            '---\n===\n',
          ),
          const [
            Token.startHeader,
            Token.id('one'),
            Token.colon,
            Token.text(''),
            Token.newline,
            Token.newline,
            Token.id('two'),
            Token.colon,
            Token.text('some data '),
            Token.newline,
            Token.endHeader,
            Token.startBody,
            Token.endBody,
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
          hasSyntaxError('SyntaxError: expected end-of-header marker "---"\n'
              '>  at line 1 column 1:\n'
              '>  :\n'
              '>  ^\n'),
        );
      });

      test('short separator', () {
        expect(
          () => tokenize('--\n===\n'),
          hasSyntaxError('SyntaxError: expected end-of-header marker "---"\n'
              '>  at line 1 column 1:\n'
              '>  --\n'
              '>  ^\n'),
        );
      });

      test('overlong separator', () {
        expect(
          tokenize('----\n----\n===\n'),
          [Token.startHeader, Token.endHeader, Token.startBody, Token.endBody],
        );
        expect(
          tokenize('------------------------------------------\n---\n===\n'),
          [Token.startHeader, Token.endHeader, Token.startBody, Token.endBody],
        );
      });

      test('explicit start&end of header', () {
        expect(
          tokenize(
            '-----------------------------------------------\n'
            'title: The_Best_Node\n'
            '-----------------------------------------------\n'
            '===\n',
          ),
          const [
            Token.startHeader,
            Token.id('title'),
            Token.colon,
            Token.text('The_Best_Node'),
            Token.newline,
            Token.endHeader,
            Token.startBody,
            Token.endBody,
          ],
        );
      });

      test('header with wrong content', () {
        expect(
          () => tokenize(
            '---\n'
            '# abc\n'
            '---\n'
            '===\n',
          ),
          hasSyntaxError(
            'SyntaxError: expected end-of-header marker "---"\n'
            '>  at line 2 column 1:\n'
            '>  # abc\n'
            '>  ^\n',
          ),
        );
      });
    });

    group('modeNodeBody', () {
      test('without final newline', () {
        expect(
          tokenize('---\n---\n==='),
          [Token.startHeader, Token.endHeader, Token.startBody, Token.endBody],
        );
      });

      test('whitespace in body', () {
        expect(
          tokenize('---\n---\n'
              '\n'
              '   \t  \r\n'
              ' // also could be some comments here\n'
              '==='),
          [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.newline,
            Token.newline,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('indentation', () {
        expect(
          tokenize('---\n---\n'
              '  alpha\n'
              '   beta\n'
              '\t     gamma\n'
              '  delta\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startIndent,
            Token.text('alpha'),
            Token.newline,
            Token.startIndent,
            Token.text('beta'),
            Token.newline,
            Token.startIndent,
            Token.text('gamma'),
            Token.newline,
            Token.endIndent,
            Token.endIndent,
            Token.text('delta'),
            Token.newline,
            Token.endIndent,
            Token.endBody,
          ],
        );
      });

      test('invalid indentation', () {
        expect(
          () => tokenize('---\n---\n'
              ' alpha\n'
              '     beta\n'
              '  gamma\n'
              '===\n'),
          hasSyntaxError('SyntaxError: inconsistent indentation\n'
              '>  at line 5 column 3:\n'
              '>    gamma\n'
              '>    ^\n'),
        );
      });

      test('dedents at end of body', () {
        expect(
          tokenize('---\n---\n'
              'one\n'
              '  two\n'
              '    three\n'
              '==='),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('one'),
            Token.newline,
            Token.startIndent,
            Token.text('two'),
            Token.newline,
            Token.startIndent,
            Token.text('three'),
            Token.newline,
            Token.endIndent,
            Token.endIndent,
            Token.endBody,
          ],
        );
      });

      test('invalid body end', () {
        expect(
          () => tokenize('---\n---\n===='),
          hasSyntaxError('SyntaxError: incomplete node body\n'
              '>  at line 3 column 5:\n'
              '>  ====\n'
              '>      ^\n'),
        );
      });
    });

    group('modeNodeBodyLine', () {
      test('option lines', () {
        expect(
          tokenize('---\n---\n'
              '->something\n'
              '  -> other\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.arrow,
            Token.text('something'),
            Token.newline,
            Token.startIndent,
            Token.arrow,
            Token.text('other'),
            Token.newline,
            Token.endIndent,
            Token.endBody,
          ],
        );
      });

      test('commands', () {
        expect(
          tokenize('---\n---\n'
              '<< >>\n'
              '<< stop >>\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startCommand,
            Token.endCommand,
            Token.newline,
            Token.startCommand,
            Token.commandStop,
            Token.endCommand,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('line speakers', () {
        expect(
          tokenize('---\n---\n'
              'Marge: Hello!\n'
              'Mr Smith: You too\n'
              'Пан_Голова :...\n'
              'Ḟḷḁṃḙ: // nothing\n'
              '𐀆𒐰ï︮𒐜   :::\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.person('Marge'),
            Token.colon,
            Token.text('Hello!'),
            Token.newline,
            Token.text('Mr Smith: You too'),
            Token.newline,
            Token.person('Пан_Голова'),
            Token.colon,
            Token.text('...'),
            Token.newline,
            Token.person('Ḟḷḁṃḙ'),
            Token.colon,
            Token.newline,
            Token.person('𐀆𒐰ï︮𒐜'),
            Token.colon,
            Token.text('::'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('repeated arrow', () {
        expect(
          tokenize('---\n---\n'
              '-> -> -> \n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.arrow,
            Token.arrow,
            Token.arrow,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('repeated character name', () {
        expect(
          tokenize('---\n---\n'
              'Pig: Horse: Moo!\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.person('Pig'),
            Token.colon,
            Token.text('Horse: Moo!'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('line with hash tags', () {
        expect(
          tokenize('---\n---\n'
              'Some text #with-tag\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('Some text'),
            Token.hashtag('#with-tag'),
            Token.newline,
            Token.endBody,
          ],
        );
      });
    });

    group('modeText', () {
      test('text with comment', () {
        expect(
          tokenize('---\n---\n'
              'some text // here be dragons\n'
              'other text   \t\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('some text'),
            Token.newline,
            Token.text('other text'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('escape sequences', () {
        expect(
          tokenize('---\n---\n'
              r'\<\{ inside \}\>'
              '\n'
              'very long \\\n'
              '  text\n'
              'line with a newline:\\n ok\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
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
            Token.endBody,
          ],
        );
      });

      test('">>" sequence', () {
        expect(
            tokenize('---\n---\n'
                '>> hello\n'
                '===\n'),
            const [
              Token.startHeader,
              Token.endHeader,
              Token.startBody,
              Token.text('>>'),
              Token.text(' hello'),
              Token.newline,
              Token.endBody,
            ]);
      });

      test('invalid escape sequence', () {
        expect(
          () => tokenize('---\n---\n'
              'some text \\a\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid escape sequence\n'
              '>  at line 3 column 12:\n'
              '>  some text \\a\n'
              '>             ^\n'),
        );
      });

      test('missing escape sequence', () {
        for (final ch in [']', '}']) {
          expect(
            () => tokenize('---\n---\ntext $ch\n'),
            hasSyntaxError(
                'SyntaxError: special character needs to be escaped\n'
                '>  at line 3 column 6:\n'
                '>  text $ch\n'
                '>       ^\n'),
          );
        }
      });

      test('expressions', () {
        expect(
          tokenize('---\n---\n'
              '{ } // noop\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });
    });

    group('modeExpression', () {
      test('expression with assorted tokens', () {
        expect(
          tokenize('---\n---\n'
              '{ \$x += 33 - 7/random() }\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.variable(r'$x'),
            Token.operatorPlusAssign,
            Token.number('33'),
            Token.operatorMinus,
            Token.number('7'),
            Token.operatorDivide,
            Token.id('random'),
            Token.startParenthesis,
            Token.endParenthesis,
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('expression with keywords', () {
        expect(
          tokenize('---\n---\n'
              '{ true * false as String }\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.constTrue,
            Token.operatorMultiply,
            Token.constFalse,
            Token.asType,
            Token.typeString,
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('expression with strings', () {
        expect(
          tokenize('---\n---\n'
              '{ \$x = "hello" + ", world" }\n'
              '{ "one\' two", \'"\' }\n'
              '{ "last \\\' \\" \\\\ one\\n" }\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.variable(r'$x'),
            Token.operatorAssign,
            Token.string('hello'),
            Token.operatorPlus,
            Token.string(', world'),
            Token.endExpression,
            Token.newline,
            Token.startExpression,
            Token.string("one' two"),
            Token.comma,
            Token.string('"'),
            Token.endExpression,
            Token.newline,
            Token.startExpression,
            Token.string('last \' " \\ one\n'),
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('expression with numbers', () {
        expect(
          tokenize('---\n---\n'
              '{ 0 -1  239444  0.5  17.1  2.  3.1415926535 111}\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.number('0'),
            Token.operatorMinus,
            Token.number('1'),
            Token.number('239444'),
            Token.number('0.5'),
            Token.number('17.1'),
            Token.number('2.'),
            Token.number('3.1415926535'),
            Token.number('111'),
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('close command within a plain text expression', () {
        expect(
          tokenize('---\n---\n'
              '{ a >> b }\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startExpression,
            Token.id('a'),
            Token.operatorGreaterThan,
            Token.operatorGreaterThan,
            Token.id('b'),
            Token.endExpression,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('invalid variable name', () {
        expect(
          () => tokenize('---\n---\n'
              '{ \$a = \$7b }\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid variable name\n'
              '>  at line 3 column 8:\n'
              '>  { \$a = \$7b }\n'
              '>         ^\n'),
        );
      });

      test('unicode variable names', () {
        expect(
          () => tokenize('---\n---\n'
              '{ \$эксперимент }\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid variable name\n'
              '>  at line 3 column 3:\n'
              '>  { \$эксперимент }\n'
              '>    ^\n'),
        );
      });

      test('invalid string', () {
        expect(
          () => tokenize('---\n---\n'
              '{ "starting... }\n'
              '===\n'),
          hasSyntaxError(
              'SyntaxError: unexpected end of line while parsing a string\n'
              '>  at line 3 column 17:\n'
              '>  { "starting... }\n'
              '>                  ^\n'),
        );
      });
    });

    group('modeCommand', () {
      test('normal commands', () {
        expect(
          tokenize('---\n---\n'
              '<< stop >>\n'
              '<< fullStop >>\n'
              '<< jump places >>\n'
              '<<wait 2>>\n'
              '<< set \$n = 2 >>  // simple\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startCommand,
            Token.commandStop,
            Token.endCommand,
            Token.newline,
            Token.startCommand,
            Token.command('fullStop'),
            Token.endCommand,
            Token.newline,
            Token.startCommand,
            Token.commandJump,
            Token.id('places'),
            Token.endCommand,
            Token.newline,
            Token.startCommand,
            Token.commandWait,
            Token.startExpression,
            Token.number('2'),
            Token.endExpression,
            Token.endCommand,
            Token.newline,
            Token.startCommand,
            Token.commandSet,
            Token.startExpression,
            Token.variable(r'$n'),
            Token.operatorAssign,
            Token.number('2'),
            Token.endExpression,
            Token.endCommand,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('if-else', () {
        expect(
          tokenize('---\n---\n'
              '<<if \$gold_amount < 10>>\n'
              "    Baker: Well, you can't afford one!\n"
              '<<endif>>\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startCommand,
            Token.commandIf,
            Token.startExpression,
            Token.variable(r'$gold_amount'),
            Token.operatorLessThan,
            Token.number('10'),
            Token.endExpression,
            Token.endCommand,
            Token.newline,
            Token.startIndent,
            Token.person('Baker'),
            Token.colon,
            Token.text("Well, you can't afford one!"),
            Token.newline,
            Token.endIndent,
            Token.startCommand,
            Token.commandEndif,
            Token.endCommand,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('user-defined commands', () {
        expect(
          tokenize('---\n---\n'
              '<<hello one two three>>\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startCommand,
            Token.command('hello'),
            Token.text('one two three'),
            Token.endCommand,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('closing brace', () {
        expect(
          () => tokenize('---\n---\n'
              '<< hello } >>\n'
              '===\n'),
          hasSyntaxError('SyntaxError: special character needs to be escaped\n'
              '>  at line 3 column 10:\n'
              '>  << hello } >>\n'
              '>           ^\n'),
        );
      });

      test('incomplete command', () {
        expect(
          () => tokenize('---\n---\n'
              '<< stop\n'
              '===\n'),
          hasSyntaxError('SyntaxError: missing command close token ">>"\n'
              '>  at line 3 column 8:\n'
              '>  << stop\n'
              '>         ^\n'),
        );
      });
    });

    group('modeMarkup', () {
      test('tokenize simple markup tag', () {
        expect(
          tokenize('---\n---\n[wave]\n===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startMarkupTag,
            Token.id('wave'),
            Token.endMarkupTag,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('tokenize closing markup tag', () {
        expect(
          tokenize('---\n---\n[/wave]\n===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startMarkupTag,
            Token.closeMarkupTag,
            Token.id('wave'),
            Token.endMarkupTag,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('tokenize self-closing markup tag', () {
        expect(
          tokenize('---\n---\n[wave/]\n===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.startMarkupTag,
            Token.id('wave'),
            Token.closeMarkupTag,
            Token.endMarkupTag,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('tokenize complex markup tag', () {
        expect(
          tokenize('---\n---\n'
              'One [red shade=12 hex="#ff0000"]color[/red]\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('One '),
            Token.startMarkupTag,
            Token.id('red'),
            Token.id('shade'),
            Token.operatorAssign,
            Token.number('12'),
            Token.id('hex'),
            Token.operatorAssign,
            Token.string('#ff0000'),
            Token.endMarkupTag,
            Token.text('color'),
            Token.startMarkupTag,
            Token.closeMarkupTag,
            Token.id('red'),
            Token.endMarkupTag,
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('whitespace after self-closing command', () {
        expect(
          tokenize('---\n---\n'
              'Hello [yes/] world!\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('Hello '),
            Token.startMarkupTag,
            Token.id('yes'),
            Token.closeMarkupTag,
            Token.endMarkupTag,
            Token.text('world!'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('unclosed markup tag', () {
        expect(
          () => tokenize('---\n---\n[blue\n===\n'),
          hasSyntaxError(
            'SyntaxError: missing markup tag close token "]"\n'
            '>  at line 3 column 6:\n'
            '>  [blue\n'
            '>       ^\n',
          ),
        );
      });
    });

    group('modeTextEnd', () {
      test('hashtags in lines', () {
        expect(
          tokenize('---\n---\n'
              'line1 #tag #some:other@tag! // whatever\n'
              'line2 { 33 } #here-be-dragons//2\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('line1'),
            Token.hashtag('#tag'),
            Token.hashtag('#some:other@tag!'),
            Token.newline,
            Token.text('line2 '),
            Token.startExpression,
            Token.number('33'),
            Token.endExpression,
            Token.hashtag('#here-be-dragons'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('comments in lines', () {
        expect(
          tokenize('---\n---\n'
              'line1 // whatever\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('line1'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('commands in lines', () {
        expect(
          tokenize('---\n---\n'
              '-> Sure I am! The boss knows me! <<if \$reputation > 10>>\n'
              '-> Please?\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.arrow,
            Token.text('Sure I am! The boss knows me!'),
            Token.startCommand,
            Token.commandIf,
            Token.startExpression,
            Token.variable(r'$reputation'),
            Token.operatorGreaterThan,
            Token.number('10'),
            Token.endExpression,
            Token.endCommand,
            Token.newline,
            Token.arrow,
            Token.text('Please?'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('multiple commands and hashtags', () {
        expect(
          tokenize('---\n---\n'
              '#one <<two>> <<stop>> #four\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.hashtag('#one'),
            Token.startCommand,
            Token.command('two'),
            Token.endCommand,
            Token.startCommand,
            Token.commandStop,
            Token.endCommand,
            Token.hashtag('#four'),
            Token.newline,
            Token.endBody,
          ],
        );
      });

      test('text with escaped content', () {
        expect(
          tokenize('---\n---\n'
              'One \\{ two\n'
              '===\n'),
          const [
            Token.startHeader,
            Token.endHeader,
            Token.startBody,
            Token.text('One '),
            Token.text('{'),
            Token.text(' two'),
            Token.newline,
            Token.endBody,
          ],
        );
      });
    });

    // This group is for testing the error mechanism itself, not any particular
    // error conditions.
    group('errors', () {
      test('long line, error near the start', () {
        expect(
          () => tokenize('---\n---\n'
              '<<set alpha beta gamma delta epsilon ~ zeta eta theta iota '
              'kappa lambda mu nu xi omicron pi rho sigma tau >>\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid token\n'
              '>  at line 3 column 38:\n'
              '>  <<set alpha beta gamma delta epsilon ~ zeta eta theta iota '
              'kappa lambda mu...\n'
              '>                                       ^\n'),
        );
      });

      test('long line, error near the end', () {
        expect(
          () => tokenize('---\n---\n'
              '<<set alpha beta gamma delta epsilon zeta eta theta iota kappa '
              'lambda mu nu xi omicron pi rho @ sigma tau upsilon phi chi>>\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid token\n'
              '>  at line 3 column 95:\n'
              '>  ...theta iota kappa lambda mu nu xi omicron pi rho @ sigma '
              'tau upsilon phi chi>>\n'
              '>                                                     ^\n'),
        );
      });

      test('long line, error in the middle', () {
        expect(
          () => tokenize('---\n---\n'
              '<<set alpha beta gamma delta epsilon zeta eta theta iota kappa '
              'lambda ` mu nu xi omicron pi rho sigma tau upsilon phi chi psi '
              'omega>>\n'
              '===\n'),
          hasSyntaxError('SyntaxError: invalid token\n'
              '>  at line 3 column 71:\n'
              '>  ...on zeta eta theta iota kappa lambda ` mu nu xi omicron '
              'pi rho sigma tau...\n'
              '>                                         ^\n'),
        );
      });

      test('error at end of line', () {
        const text = '---\n---\nSome text\n===\n';
        final tokens0 = tokenize(text);
        expect(tokens0[4], Token.newline);

        final tokens1 = tokenize(text, addErrorTokenAtIndex: 4);
        final errorToken = tokens1.removeAt(4);
        expect(tokens1, tokens0);
        expect(errorToken.type, TokenType.error);
        expect(
          errorToken.content,
          '>  at line 3 column 10:\n'
          '>  Some text\n'
          '>           ^',
        );
      });

      test('error at the end of text', () {
        const text = '---\n---\nSome text\n===\n';
        final tokens0 = tokenize(text);
        expect(tokens0.length, 6);

        final tokens1 = tokenize(text, addErrorTokenAtIndex: 6);
        final errorToken = tokens1.removeAt(6);
        expect(tokens1, tokens0);
        expect(errorToken.type, TokenType.error);
        expect(
          errorToken.content,
          '>  at line 5 column 1:\n'
          '>  \n'
          '>  ^',
        );
      });
    });
  });
}
