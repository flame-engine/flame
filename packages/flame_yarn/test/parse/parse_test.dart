import 'package:flame_yarn/flame_yarn.dart';
import 'package:flame_yarn/src/parse/parser.dart';
import 'package:flame_yarn/src/structure/dialogue.dart';
import 'package:test/test.dart';

import 'tokenize_test.dart';

void main() {
  // The tests here are further organized into subgroups according to which
  // part of the parser they engage.
  group('parse', () {
    group('parseMain', () {
      test('empty input', () {
        final yarn = YarnProject();
        parse('', yarn);
        expect(yarn.nodes.isEmpty, true);
        expect(yarn.variables.isEmpty, true);
      });

      test('single node', () {
        final yarn = YarnProject();
        parse(
          'title: Alpha\n'
          '---\n'
          '===\n',
          yarn,
        );
        expect(yarn.nodes.length, 1);
        expect(yarn.nodes.containsKey('Alpha'), true);
      });

      test('multiple nodes', () {
        final yarn = YarnProject();
        parse(
          'title: Alpha\n---\n===\n'
          ' // another node\n'
          'title: Beta\n---\n===\n'
          'title: Gamma\n---\n===\n',
          yarn,
        );
        expect(yarn.nodes.length, 3);
        expect(yarn.nodes.containsKey('Alpha'), true);
        expect(yarn.nodes.containsKey('Beta'), true);
        expect(yarn.nodes.containsKey('Gamma'), true);
      });
    });

    group('parseNodeHeader', () {
      test('node with tags', () {
        final yarn = YarnProject();
        yarn.parse('title: Romeo v Juliette\n'
            'requires: Montagues and Capulets\n'
            'location: fair Verona\n'
            '---\n===\n');
        final node = yarn.nodes['Romeo v Juliette'];
        expect(node, isNotNull);
        expect(node!.title, 'Romeo v Juliette');
        expect(node.tags, isNotNull);
        expect(node.tags!['requires'], 'Montagues and Capulets');
        expect(node.tags!['location'], 'fair Verona');
      });

      test('multiple colons', () {
        expect(
          () => YarnProject().parse('title:: Hamlet\n---\n===\n'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 1 column 7:\n'
              '>  title:: Hamlet\n'
              '>        ^\n'),
        );
      });

      test('node without a title', () {
        expect(
          () => YarnProject().parse('Title: Despicable Me!\n---\n===\n'),
          hasSyntaxError('SyntaxError: node does not have a title\n'
              '>  at line 2 column 1:\n'
              '>  ---\n'
              '>  ^\n'),
        );
      });

      test('node with multiple titles', () {
        expect(
          () => YarnProject().parse('\n'
              'title: one\n'
              'keyword: value\n'
              'title: two\n'
              '---\n===\n'),
          hasSyntaxError('SyntaxError: a node can only have one title\n'
              '>  at line 4 column 1:\n'
              '>  title: two\n'
              '>  ^\n'),
        );
      });

      test('multiple nodes with same titles', () {
        expect(
          () => YarnProject().parse('\n'
              'title: xyz\n'
              '---\n===\n'
              'title: xyz\n'
              '---\n===\n'),
          hasSyntaxError(
            'SyntaxError: node with title "xyz" has already been defined\n'
            '>  at line 5 column 1:\n'
            '>  title: xyz\n'
            '>  ^\n',
          ),
        );
      });
    });

    group('parseNodeBody', () {
      test('indent in a body', () {
        expect(
          () => YarnProject().parse('title:a\n---\n    hi\n===\n'),
          hasSyntaxError('SyntaxError: unexpected indent\n'
              '>  at line 3 column 1:\n'
              '>      hi\n'
              '>  ^\n'),
        );
      });
    });

    group('parseStatementList', () {
      test('multiple lines', () {
        final yarn = YarnProject()
          ..parse('title: test\n'
              '---\n'
              'Jupyter\n'
              'Saturn\n'
              'Uranus\n'
              '===\n');
        final node = yarn.nodes['test']!;
        expect(node.lines.length, 3);
        for (var i = 0; i < 3; i++) {
          expect(node.lines[i], isA<Dialogue>());
          final line = node.lines[i] as Dialogue;
          expect(line.speaker, isNull);
          expect(line.tags, isNull);
          expect(line.content.value, ['Jupyter', 'Saturn', 'Uranus'][i]);
        }
      });
    });

    group('parseDialogueLine', () {
      test('line with a speaker', () {
        final yarn = YarnProject()
            ..parse('title:A\n---\nMrGoo: whatever\n===\n');
        expect(yarn.nodes['A']!.lines.first, isA<Dialogue>());
        final line = yarn.nodes['A']!.lines[0] as Dialogue;
        expect(line.speaker, 'MrGoo');
        expect(line.content.value, 'whatever');
      });

      test('line with multiple expressions', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n{1} {false} {"fake news"}\n===\n');
        expect(yarn.nodes['A']!.lines.first, isA<Dialogue>());
        final line = yarn.nodes['A']!.lines[0] as Dialogue;
        expect(line.speaker, isNull);
        expect(line.content.value, '1 false fake news');
      });

      test('line with hashtags', () {
        final yarn = YarnProject()
          ..parse('title:A\n---\n.hello #here #zzz\n===\n');
        final node = yarn.nodes['A']!;
        expect(node.lines.length, 1);
        final line = node.lines[0] as Dialogue;
        expect(line.tags, isNotNull);
        expect(line.tags!.length, 2);
        expect(line.tags, contains('#here'));
        expect(line.tags, contains('#zzz'));
      });

      test('line with a command', () {
        expect(
          () => YarnProject().parse('title:A\n---\nz <<if true>>\n===\n'),
          hasSyntaxError(
              'SyntaxError: commands are not allowed on a dialogue line\n'
              '>  at line 3 column 3:\n'
              '>  z <<if true>>\n'
              '>    ^\n'),
        );
      });

      test('line with no content but a hashtag', () {
        expect(
          () => YarnProject().parse('title:A\n---\n#tag\n===\n'),
          hasSyntaxError('SyntaxError: unexpected token\n'
              '>  at line 3 column 1:\n'
              '>  #tag\n'
              '>  ^\n'),
        );
      });
    });

    group('parseOption', () {
      // test('option with a non-boolean condition', () {
      //   expect(
      //         () => YarnProject().parse(
      //       'title:A\n---\n-> ok! <<if 42 % 2>>\n===\n',
      //     ),
      //     hasSyntaxError(
      //         'SyntaxError: the condition in "if" should be boolean\n'
      //             '>  at line 3 column 10:\n'
      //             '>  -> ok! <<if 42 % 2>>\n'
      //             '>           ^\n'),
      //   );
      // });
    });

    group('parseExpression', () {
      test('unary minus', () {
        final yarn = YarnProject()
          ..setVariable(r'$x', 42)
          ..parse('title: test\n---\n'
              '{ -7 + 1 }\n'
              '{ 2 * -7 }\n'
              '{ -\$x }\n'
              '{ -(3 + 111) }\n'
              '===\n');
        expect(
          yarn.nodes['test']!.lines
              .map((line) => num.parse((line as Dialogue).content.value))
              .toList(),
          [-6, -14, -42, -114],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ -"banana" }\n===\n'),
          hasSyntaxError(
              'SyntaxError: unary minus can only be applied to numbers\n'
              '>  at line 3 column 4:\n'
              '>  { -"banana" }\n'
              '>     ^\n'),
        );
      });

      test('add', () {
        final yarn = YarnProject()
          ..setVariable(r'$world', 'world')
          ..parse('title: test\n---\n'
              '{ 2.16 + 4.6 + 9 }\n'
              '{ "hello," + " " + \$world }\n'
              '===\n');
        expect(
          yarn.nodes['test']!.lines
              .map((line) => (line as Dialogue).content.value)
              .toList(),
          ['15.76', 'hello, world'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 + " swords" }\n===\n'),
          hasSyntaxError(
              'SyntaxError: both lhs and rhs of + must be numeric or strings\n'
              '>  at line 3 column 5:\n'
              '>  { 3 + " swords" }\n'
              '>      ^\n'),
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 + true }\n===\n'),
          hasSyntaxError(
              'SyntaxError: both lhs and rhs of + must be numeric or strings\n'
              '>  at line 3 column 5:\n'
              '>  { 3 + true }\n'
              '>      ^\n'),
        );
      });

      test('subtract', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 22 - 7 - 1 }\n'
              '{ "hello," - "hell" - "paradise" }\n'
              '===\n');
        expect(
          yarn.nodes['test']!.lines
              .map((line) => (line as Dialogue).content.value)
              .toList(),
          ['14', 'o,'],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ 3 - "zero" }\n===\n'),
          hasSyntaxError(
              'SyntaxError: both lhs and rhs of - must be numeric or strings\n'
              '>  at line 3 column 5:\n'
              '>  { 3 - "zero" }\n'
              '>      ^\n'),
        );
      });

      test('multiply', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 11 * 8 * 0.5 }\n'
              '{ "hello! " * 3 }\n'
              '===\n');
        expect(
          yarn.nodes['test']!.lines
              .map((line) => (line as Dialogue).content.value)
              .toList(),
          ['44.0', 'hello! hello! hello! '],
        );
        expect(
          () => yarn.parse('title:E\n---\n{ "x" * "zero" }\n===\n'),
          hasSyntaxError('SyntaxError: both lhs and rhs of * must be numeric\n'
              '>  at line 3 column 7:\n'
              '>  { "x" * "zero" }\n'
              '>        ^\n'),
        );
      });

      test('divide', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{ 48 / 2 / 3 }\n'
              '===\n');
        expect(
          (yarn.nodes['test']!.lines[0] as Dialogue).content.value,
          '8.0',
        );
        expect(
          () => yarn.parse('title:E\n---\n{ "x" / "y" }\n===\n'),
          hasSyntaxError('SyntaxError: both lhs and rhs of / must be numeric\n'
              '>  at line 3 column 7:\n'
              '>  { "x" / "y" }\n'
              '>        ^\n'),
        );
      });

      test('complicated expressions', () {
        final yarn = YarnProject()
          ..parse('title: test\n---\n'
              '{(4 - 5)}\n'
              '{ 2 + 7 * 3 - 1 }\n'
              '{ 44 / (3 - 1) % 15 }\n'
              '===\n');
        final node = yarn.nodes['test']!;
        expect(node.lines.length, 3);
        expect((node.lines[0] as Dialogue).content.value, '-1');
        expect((node.lines[1] as Dialogue).content.value, '22');
        expect((node.lines[2] as Dialogue).content.value, '7.0');
      });

      test('unknown variable', () {
        expect(
          () => YarnProject().parse('title:A\n---\n{ \$x + 1 }\n===\n'),
          hasNameError('NameError: variable \$x is not defined\n'
              '>  at line 3 column 3:\n'
              '>  { \$x + 1 }\n'
              '>    ^\n'),
        );
      });
    });
  });
}

Matcher hasNameError(String message) {
  return throwsA(
    isA<NameError>().having((e) => e.toString(), 'toString', message),
  );
}
