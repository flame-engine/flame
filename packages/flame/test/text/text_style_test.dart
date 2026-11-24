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

    test('document style can be copied', () {
      final style = DocumentStyle(
        text: InlineTextStyle(
          fontSize: 8,
        ),
        boldText: InlineTextStyle(
          fontWeight: FontWeight.w900,
        ),
        paragraph: const BlockStyle(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
        ),
        background: BackgroundStyle(
          color: const Color(0xFFFF00FF),
        ),
      );
      final newStyle = style.copyWith(
        DocumentStyle(
          text: InlineTextStyle(
            fontSize: 10,
          ),
          boldText: InlineTextStyle(
            fontWeight: FontWeight.w900,
          ),
          italicText: InlineTextStyle(
            fontStyle: FontStyle.italic,
          ),
          paragraph: const BlockStyle(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.zero,
          ),
        ),
      );
      expect(newStyle.text.fontSize, 10);
      expect(newStyle.boldText.fontWeight, FontWeight.w900);
      expect(newStyle.italicText.fontStyle, FontStyle.italic);
      expect(newStyle.paragraph.margin, const EdgeInsets.all(10));
      expect(newStyle.paragraph.padding, EdgeInsets.zero);
      expect(
        newStyle.background!.backgroundPaint!.color,
        const Color(0xFFFF00FF),
      );
    });

    group('document style copyWith keeps what other does not set', () {
      test('text styles', () {
        final style = DocumentStyle(
          text: InlineTextStyle(fontSize: 8),
          boldText: InlineTextStyle(fontWeight: FontWeight.w900),
          italicText: InlineTextStyle(fontStyle: FontStyle.normal),
          codeText: InlineTextStyle(fontFamily: 'Courier'),
          strikethroughText: InlineTextStyle(
            decoration: TextDecoration.overline,
          ),
        );
        final newStyle = style.copyWith(DocumentStyle(width: 100));
        expect(newStyle.width, 100);
        expect(newStyle.text.fontSize, 8);
        expect(newStyle.boldText.fontWeight, FontWeight.w900);
        expect(newStyle.italicText.fontStyle, FontStyle.normal);
        expect(newStyle.codeText.fontFamily, 'Courier');
        expect(newStyle.strikethroughText.decoration, TextDecoration.overline);
      });

      test('block styles', () {
        final block = BlockStyle(
          margin: const EdgeInsets.all(3),
          text: InlineTextStyle(fontScale: 3),
        );
        final style = DocumentStyle(
          paragraph: block,
          header1: block,
          header2: block,
          header3: block,
          header4: block,
          header5: block,
          header6: block,
        );
        final newStyle = style.copyWith(DocumentStyle(width: 100));
        for (final copied in [
          newStyle.paragraph,
          newStyle.header1,
          newStyle.header2,
          newStyle.header3,
          newStyle.header4,
          newStyle.header5,
          newStyle.header6,
        ]) {
          expect(copied.margin, const EdgeInsets.all(3));
          expect(copied.text!.fontScale, 3);
        }
      });

      test('padding', () {
        final style = DocumentStyle(padding: const EdgeInsets.all(16));
        expect(
          style.copyWith(DocumentStyle(width: 100)).padding,
          const EdgeInsets.all(16),
        );
        expect(
          style.copyWith(DocumentStyle(padding: EdgeInsets.zero)).padding,
          EdgeInsets.zero,
        );
      });

      test('custom styles', () {
        final style = DocumentStyle(
          customStyles: {
            'author': InlineTextStyle(fontSize: 12, fontFamily: 'Arial'),
            'date': InlineTextStyle(fontSize: 10),
          },
        );
        final newStyle = style.copyWith(
          DocumentStyle(
            customStyles: {
              'author': InlineTextStyle(fontSize: 14),
              'title': InlineTextStyle(fontSize: 20),
            },
          ),
        );
        expect(newStyle.getCustomStyle('author')!.fontSize, 14);
        expect(newStyle.getCustomStyle('author')!.fontFamily, 'Arial');
        expect(newStyle.getCustomStyle('date')!.fontSize, 10);
        expect(newStyle.getCustomStyle('title')!.fontSize, 20);
        expect(
          style
              .copyWith(DocumentStyle(width: 100))
              .getCustomStyle('date')!
              .fontSize,
          10,
        );
      });

      test('background border', () {
        final style = DocumentStyle(
          background: BackgroundStyle(
            color: const Color(0xFF00FF00),
            borderColor: const Color(0xFFFF0000),
            borderWidth: 2,
            borderRadius: 5,
          ),
        );
        final newStyle = style.copyWith(
          DocumentStyle(
            background: BackgroundStyle(color: const Color(0xFF0000FF)),
          ),
        );
        final background = newStyle.background!;
        expect(background.backgroundPaint!.color, const Color(0xFF0000FF));
        expect(background.borderPaint!.color, const Color(0xFFFF0000));
        expect(background.borderPaint!.strokeWidth, 2);
        expect(background.borderWidths, const EdgeInsets.all(2));
        expect(background.borderRadius, 5);

        final overridden = style.copyWith(
          DocumentStyle(
            background: BackgroundStyle(borderWidth: 0, borderRadius: 0),
          ),
        );
        expect(overridden.background!.borderWidths, EdgeInsets.zero);
        expect(overridden.background!.borderRadius, 0);
        expect(
          overridden.background!.backgroundPaint!.color,
          const Color(0xFF00FF00),
        );
      });
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
      final paragraph = groupElement.children.first as ParagraphTextElement;
      final span = paragraph.textPainter.text! as TextSpan;
      final styles = span.children!.map((child) => child.style!).toList();

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
