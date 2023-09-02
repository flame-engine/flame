import 'dart:io';

import 'package:flame/text.dart';
import 'package:flame_markdown/flame_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameMarkdown#toDocument', () {
    test('just plain text', () {
      final doc = FlameMarkdown.toDocument('Hello world!');

      _expectDocument(doc, [
        (node) => _expectSimpleParagraph(node, 'Hello world!'),
      ]);
    });

    test('rich text', () {
      final doc = FlameMarkdown.toDocument('**Flame**: Hello, _world_!');

      _expectDocument(doc, [
        (node) => _expectParagraph(node, (p) {
              _expectGroup(p, [
                (node) => _expectBold(node, 'Flame'),
                (node) => _expectPlain(node, ': Hello, '),
                (node) => _expectItalic(node, 'world'),
                (node) => _expectPlain(node, '!'),
              ]);
            }),
      ]);
    });

    test('all header levels', () {
      final doc = FlameMarkdown.toDocument(
        '# h1\n'
        '## h2\n'
        '### h3\n'
        '#### h4\n'
        '##### h5\n'
        '###### h6\n',
      );

      _expectDocument(doc, [
        (node) => _expectHeader(node, 1, 'h1'),
        (node) => _expectHeader(node, 2, 'h2'),
        (node) => _expectHeader(node, 3, 'h3'),
        (node) => _expectHeader(node, 4, 'h4'),
        (node) => _expectHeader(node, 5, 'h5'),
        (node) => _expectHeader(node, 6, 'h6'),
      ]);
    });

    test('several paragraphs with header', () {
      final markdown = File('example/assets/fire_and_ice.md').readAsStringSync();
      final doc = FlameMarkdown.toDocument(markdown);

      _expectDocument(doc, [
        (node) => _expectHeader(node, 1, 'Fire and Ice'),
        (node) => _expectParagraph(node, (p) {
              _expectGroup(p, [
                (node) => _expectPlain(node, 'Some say the world will end in '),
                (node) => _expectBold(node, 'fire'),
                (node) => _expectPlain(node, ','),
              ]);
            }),
        (node) => _expectParagraph(
              node,
              (p) => _expectGroup(p, [
                (node) => _expectPlain(node, 'Some say in '),
                (node) => _expectItalic(node, 'ice'),
                (node) => _expectPlain(node, '.'),
              ]),
            ),
        (node) => _expectSimpleParagraph(
              node,
              "From what I've tasted of desire",
            ),
        (node) => _expectParagraph(node, (p) {
              _expectGroup(p, [
                (node) => _expectPlain(node, 'I hold with those who favor '),
                (node) => _expectBold(node, 'fire'),
                (node) => _expectPlain(node, '.'),
              ]);
            }),
      ]);
    });
  });
}

void _expectBold(InlineTextNode node, String text) {
  expect(node, isA<BoldTextNode>());
  final content = (node as BoldTextNode).child;
  expect(content, isA<PlainTextNode>());
  expect((content as PlainTextNode).text, text);
}

void _expectItalic(InlineTextNode node, String text) {
  expect(node, isA<ItalicTextNode>());
  final content = (node as ItalicTextNode).child;
  expect(content, isA<PlainTextNode>());
  expect((content as PlainTextNode).text, text);
}

void _expectPlain(InlineTextNode node, String text) {
  expect(node, isA<PlainTextNode>());
  final span = node as PlainTextNode;
  expect(span.text, text);
}

void _expectParagraph(
  BlockNode node,
  void Function(InlineTextNode) expectChild,
) {
  expect(node, isA<ParagraphNode>());
  final p = node as ParagraphNode;
  expectChild(p.child);
}

void _expectSimpleParagraph(BlockNode node, String text) {
  _expectParagraph(node, (child) => _expectPlain(child, text));
}

void _expectHeader(BlockNode node, int level, String text) {
  expect(node, isA<HeaderNode>());
  final header = node as HeaderNode;
  expect(header.level, level);
  expect(header.child, isA<PlainTextNode>());
  expect((header.child as PlainTextNode).text, text);
}

void _expectGroup(
  InlineTextNode node,
  List<void Function(InlineTextNode)> expectChildren,
) {
  expect(node, isA<GroupTextNode>());
  final group = node as GroupTextNode;
  expect(group.children, hasLength(expectChildren.length));
  for (final (idx, expectChild) in expectChildren.indexed) {
    expectChild(group.children[idx]);
  }
}

void _expectDocument(
  DocumentRoot root,
  List<void Function(BlockNode)> expectChildren,
) {
  expect(root.children, hasLength(expectChildren.length));
  for (final (idx, expectChild) in expectChildren.indexed) {
    expectChild(root.children[idx]);
  }
}
