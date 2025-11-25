import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

void main() {
  group('text elements', () {
    test('bounding box for empty group', () {
      final emptyGroup = GroupElement(width: 0, height: 0, children: []);
      expect(emptyGroup.boundingBox, Rect.zero);
    });

    test('bounding box for inline elements', () {
      final document = DocumentRoot([
        ParagraphNode.group([
          PlainTextNode('Hello'),
        ]),
      ]);

      final element1 = document.format(
        DocumentStyle(
          paragraph: const BlockStyle(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
          ),
        ),
        width: 80,
        height: 16,
      );
      const expected = Rect.fromLTWH(0, 0, 80, 16);

      expect(element1.boundingBox, expected);
      final element2 = element1.children.single as GroupElement;
      expect(element2.boundingBox, expected);
      final element3 = element2.children.single as InlineTextElement;
      expect(element3.boundingBox, expected);
    });

    test('bounding box is composed', () {
      final document = DocumentRoot([
        ParagraphNode.group([
          PlainTextNode('Hello, '),
          PlainTextNode('there'),
        ]),
        ParagraphNode.group([
          ItalicTextNode.simple('General '),
          BoldTextNode.simple('Kenobi'),
        ]),
      ]);

      final element1 = document.format(
        DocumentStyle(
          paragraph: const BlockStyle(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
          ),
        ),
        width: 600,
        height: 400,
      );
      expect(element1.boundingBox, const Rect.fromLTWH(0, 0, 224, 32));
      final element2 = element1.children[0] as GroupElement;
      expect(element2.boundingBox, const Rect.fromLTWH(0, 0, 192, 16));
      final element3 = element1.children[1] as GroupElement;
      expect(element3.boundingBox, const Rect.fromLTWH(0, 16, 224, 16));
    });
  });
}
