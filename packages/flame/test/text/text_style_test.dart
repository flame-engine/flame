import 'package:flame/src/text/elements/group_element.dart';
import 'package:flame/src/text/elements/group_text_element.dart';
import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group('text styles', () {
    test('document style defaults are applied', () {
      final style = DocumentStyle();
      expect(style.text.fontSize, 16);
      expect(style.boldText.fontWeight, FontWeight.bold);
      expect(style.italicText.fontStyle, FontStyle.italic);
      expect(style.paragraph.margin, const EdgeInsets.all(6));
      expect(style.paragraph.padding, EdgeInsets.zero);
    });

    test('document style parameters are respected', () {
      final style = DocumentStyle(
        text: InlineTextStyle(
          fontSize: 8,
        ),
        boldText: InlineTextStyle(
          fontWeight: FontWeight.w900,
        ),
        italicText: InlineTextStyle(
          fontStyle: FontStyle.normal,
        ),
        paragraph: const BlockStyle(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
      );
      expect(style.text.fontSize, 8);
      expect(style.boldText.fontWeight, FontWeight.w900);
      expect(style.italicText.fontStyle, FontStyle.normal);
      expect(style.paragraph.margin, EdgeInsets.zero);
      expect(style.paragraph.padding, EdgeInsets.zero);
    });

    test('styles are cascading', () {
      final style = DocumentStyle(
        width: 600.0,
        height: 400.0,
        text: InlineTextStyle(
          fontFamily: 'Helvetica',
          fontSize: 8,
        ),
        boldText: InlineTextStyle(
          fontFamily: 'Arial',
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
        italicText: InlineTextStyle(
          fontFamily: 'Arial',
          fontSize: 6,
          fontStyle: FontStyle.italic,
        ),
        paragraph: BlockStyle(
          text: InlineTextStyle(
            fontSize: 12,
          ),
        ),
      );
      final document = DocumentRoot([
        ParagraphNode.group([
          PlainTextNode('This is '),
          BoldTextNode.simple('my'),
          PlainTextNode(' town -  '),
          ItalicTextNode.simple('The Sheriff'),
        ]),
      ]);

      final element = document.format(style);
      final groupElement = element.children.first as GroupElement;
      final groupTextElement = groupElement.children.first as GroupTextElement;
      final styles = groupTextElement.children.map((e) {
        return (e as TextPainterTextElement).textPainter.text!.style!;
      }).toList();

      expect(styles[0].fontSize, 12);
      expect(styles[0].fontWeight, isNull);
      expect(styles[0].fontStyle, isNull);
      expect(styles[0].fontFamily, 'Helvetica');

      expect(styles[1].fontSize, 10);
      expect(styles[1].fontWeight, FontWeight.w900);
      expect(styles[1].fontStyle, isNull);
      expect(styles[1].fontFamily, 'Arial');

      expect(styles[2].fontSize, 12);
      expect(styles[2].fontWeight, isNull);
      expect(styles[2].fontStyle, isNull);
      expect(styles[2].fontFamily, 'Helvetica');

      expect(styles[3].fontSize, 6);
      expect(styles[3].fontWeight, isNull);
      expect(styles[3].fontStyle, FontStyle.italic);
      expect(styles[3].fontFamily, 'Arial');
    });
  });
}
