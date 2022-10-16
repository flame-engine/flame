import 'package:flame_yarn/flame_yarn.dart';
import 'package:flame_yarn/src/parse/parser.dart';
import 'package:test/test.dart';

import 'tokenize_test.dart';

void main() {
  // The tests here are further organized into subgroups according to which
  // part of the parser they engage.
  group('parse', () {
    group('parseMain', () {
      test('empty input', () {
        final yarn = YarnBall();
        parse('', yarn);
        expect(yarn.nodes.isEmpty, true);
        expect(yarn.variables.isEmpty, true);
      });

      test('single node', () {
        final yarn = YarnBall();
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
        final yarn = YarnBall();
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
        final yarn = YarnBall();
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
          () => YarnBall().parse('title:: Hamlet\n---\n===\n'),
          hasSyntaxError('SyntaxError: unexpected token'),
        );
      });

      test('node without a title', () {
        expect(
          () => YarnBall().parse('Title: Despicable Me!\n---\n===\n'),
          hasSyntaxError('SyntaxError: node does not have a title'),
        );
      });

      test('node with multiple titles', () {
        expect(
          () => YarnBall().parse('\n'
              'title: one\n'
              'keyword: value\n'
              'title: two\n'
              '---\n===\n'),
          hasSyntaxError('SyntaxError: a node can only have one title'),
        );
      });

      test('multiple nodes with same titles', () {
        expect(
          () => YarnBall().parse('\n'
              'title: xyz\n'
              '---\n===\n'
              'title: xyz\n'
              '---\n===\n'),
          hasSyntaxError(
            'SyntaxError: node with title "xyz" has already been defined',
          ),
        );
      });
    });

    group('parseBody', () {
      test('indent in a body', () {
        expect(
          () => YarnBall().parse('title:a\n---\n hi\n===\n'),
          hasSyntaxError('SyntaxError: unexpected indent'),
        );
      });
    });
  });
}
