import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('line breaking', () {
    // In the test font every character is `fontSize` wide, i.e. 10px.
    final style = DocumentStyle(
      text: InlineTextStyle(fontSize: 10),
      codeText: InlineTextStyle(fontSize: 10),
      boldText: InlineTextStyle(fontSize: 10),
      paragraph: const BlockStyle(padding: EdgeInsets.zero),
    );

    ParagraphTextElement layOutParagraph(
      List<InlineTextNode> nodes,
      double width, {
      DocumentStyle? documentStyle,
    }) {
      final document = DocumentRoot([ParagraphNode.group(nodes)]);
      final block = document
          .format(documentStyle ?? style, width: width)
          .children
          .single;
      return (block as GroupElement).children.single as ParagraphTextElement;
    }

    List<String> layOut(List<InlineTextNode> nodes, double width) {
      return layOutParagraph(
        nodes,
        width,
      ).lines.map((line) => line.trim()).toList();
    }

    test('breaks between words', () {
      expect(
        layOut([PlainTextNode('foo to bars.')], 110),
        ['foo to', 'bars.'],
      );
    });

    test('does not break trailing punctuation on separate code node', () {
      expect(
        layOut([
          PlainTextNode('foo to '),
          CodeTextNode.simple('bars'),
          PlainTextNode('.'),
        ], 110),
        ['foo to', 'bars.'],
      );
    });

    test('does not break trailing punctuation on separate bold node', () {
      expect(
        layOut([
          PlainTextNode('foo to '),
          BoldTextNode.simple('bars'),
          PlainTextNode(', and'),
        ], 110),
        ['foo to', 'bars, and'],
      );
    });

    test('keeps together a word across several nodes', () {
      expect(
        layOut([
          PlainTextNode('aa '),
          PlainTextNode('b'),
          CodeTextNode.simple('c'),
          BoldTextNode.simple('d'),
          PlainTextNode('e f'),
        ], 50),
        // cSpell:ignore bcde
        ['aa', 'bcde', 'f'],
      );
    });

    test('keeps a span next to nested group content together', () {
      expect(
        layOut([
          PlainTextNode('foo to '),
          CodeTextNode.group([
            PlainTextNode('ba'),
            BoldTextNode.simple('rs'),
          ]),
          PlainTextNode('.'),
        ], 110),
        ['foo to', 'bars.'],
      );
    });

    test('only moves the last word of a span that ends glued', () {
      expect(
        layOut([
          BoldTextNode.simple('foo to bars'),
          PlainTextNode('.'),
        ], 110),
        ['foo to', 'bars.'],
      );
    });

    test('still breaks at whitespace next to a node', () {
      expect(
        layOut([
          PlainTextNode('foo to'),
          CodeTextNode.simple(' bars'),
        ], 100),
        ['foo to', 'bars'],
      );
    });

    test('breaks inside a glued run that is wider than a line', () {
      expect(
        layOut([
          PlainTextNode('a '),
          CodeTextNode.simple('bbbb'),
          PlainTextNode('ccc'),
        ], 50),
        // cSpell:ignore bbb bccc
        ['a bbb', 'bccc'],
      );
    });

    test('breaks at hard line breaks', () {
      expect(
        layOut([PlainTextNode('foo\nbar baz')], 200),
        ['foo', 'bar baz'],
      );
    });

    test('breaks text without spaces at script boundaries', () {
      expect(
        layOut([PlainTextNode('こんにちは世界')], 50),
        ['こんにちは', '世界'],
      );
    });

    test('lays out lines below each other', () {
      final paragraph = layOutParagraph([PlainTextNode('foo to bars.')], 110);
      final lines = paragraph.lineMetrics;
      expect(lines, hasLength(2));
      expect(lines[0].baseline, lessThan(lines[1].baseline));
      expect(paragraph.height, lines[0].height + lines[1].height);
    });

    test('justifies all but the last line', () {
      final paragraph = layOutParagraph(
        [PlainTextNode('foo to bars.')],
        110,
        documentStyle: DocumentStyle(
          text: InlineTextStyle(fontSize: 10),
          paragraph: const BlockStyle(
            padding: EdgeInsets.zero,
            textAlign: TextAlign.justify,
          ),
        ),
      );
      final lines = paragraph.lineMetrics;
      expect(lines, hasLength(2));
      expect(lines[0].width, 110);
      expect(lines[1].width, 50);
    });
  });
}
