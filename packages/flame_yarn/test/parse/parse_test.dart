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
          expect(line.condition, isNull);
          expect(line.content.value, ['Jupyter', 'Saturn', 'Uranus'][i]);
        }
      });
    });

    group('parseLine', () {
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

      test('line with condition', () {
        final yarn = YarnProject()
          ..setVariable(r'$friendly', true)
          ..parse('title:A\n---\n.hello <<if \$friendly>>\n===\n');
        final node = yarn.nodes['A']!;
        expect(node.lines.length, 1);
        final line = node.lines[0] as Dialogue;
        expect(line.tags, isNull);
        expect(line.condition, isNotNull);
      });

      test('line with non-if condition', () {
        expect(
          () => YarnProject().parse('title:A\n---\n.hello <<stop>>\n===\n'),
          hasSyntaxError(
              'SyntaxError: only "if" commands are allowed on a line\n'
              '>  at line 3 column 10:\n'
              '>  .hello <<stop>>\n'
              '>           ^\n'),
        );
      });

      test('line with non-boolean condition', () {
        expect(
          () => YarnProject().parse('title:A\n---\n.hello <<if 42 % 2>>\n===\n'),
          hasSyntaxError(
              'SyntaxError: the condition in "if" should be boolean\n'
              '>  at line 3 column 13:\n'
              '>  .hello <<if 42 % 2>>\n'
              '>              ^\n'),
        );
      });
    });
  });
}
