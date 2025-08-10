import 'dart:io';
import 'dart:ui';

import 'package:flame/text.dart';
import 'package:flame_markdown/custom_attribute_syntax.dart';
import 'package:flame_markdown/flame_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart';

void main() {
  group('FlameMarkdown#toDocument', () {
    test('just plain text', () {
      final doc = FlameMarkdown.toDocument('Hello world!');

      _expectDocument(doc, [
        (node) => _expectSimpleParagraph(node, 'Hello world!'),
      ]);

      final element = doc.format(
        DocumentStyle(
          width: 1000,
          text: InlineTextStyle(
            fontSize: 12,
          ),
        ),
      );

      _expectElementGroup(element, [
        (el) => _expectElementGroup(el, [
          (el) => _expectElementTextPainter(
            el,
            'Hello world!',
            const TextStyle(
              fontSize: 12,
            ),
          ),
        ]),
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

      final element = doc.format(
        DocumentStyle(
          width: 1000,
          text: InlineTextStyle(
            fontSize: 12,
          ),
          boldText: InlineTextStyle(
            fontWeight: FontWeight.bold,
          ),
          italicText: InlineTextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      );

      _expectElementGroup(element, [
        (el) => _expectElementGroup(el, [
          (el) => _expectElementGroupText(el, [
            (el) => _expectElementTextPainter(
              el,
              'Flame',
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              ': Hello, ',
              const TextStyle(
                fontSize: 12,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              'world',
              const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              '!',
              const TextStyle(
                fontSize: 12,
              ),
            ),
          ]),
        ]),
      ]);
    });

    test('inline code block', () {
      final doc = FlameMarkdown.toDocument('Flame: `var game = FlameGame();`');

      _expectDocument(doc, [
        (node) => _expectParagraph(node, (p) {
          _expectGroup(p, [
            (node) => _expectPlain(node, 'Flame: '),
            (node) => _expectCode(node, 'var game = FlameGame();'),
          ]);
        }),
      ]);

      final element = doc.format(
        DocumentStyle(
          width: 1000,
          text: InlineTextStyle(
            fontSize: 12,
          ),
          codeText: InlineTextStyle(
            fontFamily: 'monospace',
          ),
        ),
      );

      _expectElementGroup(element, [
        (el) => _expectElementGroup(el, [
          (el) => _expectElementGroupText(el, [
            (el) => _expectElementTextPainter(
              el,
              'Flame: ',
              const TextStyle(
                fontSize: 12,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              'var game = FlameGame();',
              const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ]),
        ]),
      ]);
    });

    test('nested inline blocks', () {
      final doc = FlameMarkdown.toDocument(
        '**This _is `code` inside italics_ inside bold.**',
      );

      _expectDocument(doc, [
        (node) => _expectParagraph(node, (p) {
          _expectBoldGroup(p, [
            (node) => _expectPlain(node, 'This '),
            (node) => _expectItalicGroup(node, [
              (node) => _expectPlain(node, 'is '),
              (node) => _expectCode(node, 'code'),
              (node) => _expectPlain(node, ' inside italics'),
            ]),
            (node) => _expectPlain(node, ' inside bold.'),
          ]);
        }),
      ]);

      final element = doc.format(
        DocumentStyle(
          width: 1000,
          text: InlineTextStyle(
            fontSize: 12,
          ),
          boldText: InlineTextStyle(
            fontWeight: FontWeight.bold,
          ),
          italicText: InlineTextStyle(
            fontStyle: FontStyle.italic,
          ),
          codeText: InlineTextStyle(
            fontFamily: 'monospace',
          ),
        ),
      );

      _expectElementGroup(element, [
        (el) => _expectElementGroup(el, [
          (el) => _expectElementGroupText(el, [
            (el) => _expectElementTextPainter(
              el,
              'This ',
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            (el) => _expectElementGroupText(el, [
              (el) => _expectElementTextPainter(
                el,
                'is ',
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              (el) => _expectElementTextPainter(
                el,
                'code',
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'monospace',
                ),
              ),
              (el) => _expectElementTextPainter(
                el,
                ' inside italics',
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ]),
            (el) => _expectElementTextPainter(
              el,
              ' inside bold.',
              const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
        ]),
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
      final markdown = File(
        'example/assets/fire_and_ice.md',
      ).readAsStringSync();
      final doc = FlameMarkdown.toDocument(markdown);

      _expectDocument(doc, [
        (node) => _expectHeader(node, 1, 'Fire & Ice'),
        (node) => _expectParagraph(node, (p) {
          _expectGroup(p, [
            (node) => _expectPlain(
              node,
              // note: strike-trough is only parsed if enabled
              'Some say the world will ~~end~~ in ',
            ),
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
          "From what I've tasted of >desire<,",
        ),
        (node) => _expectParagraph(node, (p) {
          _expectGroup(p, [
            (node) => _expectPlain(node, 'I hold with those who favor '),
            (node) => _expectBold(node, 'fire'),
            (node) => _expectPlain(node, '.'),
          ]);
        }),
        // note: custom attribute is only parsed if enabled
        (node) => _expectParagraph(node, (p) {
          _expectPlain(p, '[- by Robert Frost]{.author}');
        }),
      ]);
    });

    test('strikethrough can be enabled', () {
      const markdown = 'Flame ~~will be~~ is a great game engine!';
      final doc = FlameMarkdown.toDocument(
        markdown,
        document: Document(
          encodeHtml: false,
          inlineSyntaxes: [
            StrikethroughSyntax(),
          ],
        ),
      );

      _expectDocument(doc, [
        (node) => _expectParagraph(node, (p) {
          _expectGroup(p, [
            (node) => _expectPlain(node, 'Flame '),
            (node) => _expectStrikethrough(node, 'will be'),
            (node) => _expectPlain(node, ' is a great game engine!'),
          ]);
        }),
      ]);
    });

    test('custom attributes can be enabled', () {
      const markdown =
          'This one will be [red]{.red} and this one will be [blue]{.blue}.';
      final doc = FlameMarkdown.toDocument(
        markdown,
        document: Document(
          encodeHtml: false,
          inlineSyntaxes: [
            CustomAttributeSyntax(),
          ],
        ),
      );

      _expectDocument(doc, [
        (node) => _expectParagraph(node, (p) {
          _expectGroup(p, [
            (node) => _expectPlain(node, 'This one will be '),
            (node) => _expectCustom(node, 'red', styleName: 'red'),
            (node) => _expectPlain(node, ' and this one will be '),
            (node) => _expectCustom(node, 'blue', styleName: 'blue'),
            (node) => _expectPlain(node, '.'),
          ]);
        }),
      ]);

      final element = doc.format(
        DocumentStyle(
          width: 1000,
          text: InlineTextStyle(
            fontSize: 12,
          ),
          customStyles: {
            'red': InlineTextStyle(
              color: const Color(0xFFFF0000),
            ),
            'blue': InlineTextStyle(
              color: const Color(0xFF0000FF),
            ),
          },
        ),
      );

      _expectElementGroup(element, [
        (el) => _expectElementGroup(el, [
          (el) => _expectElementGroupText(el, [
            (el) => _expectElementTextPainter(
              el,
              'This one will be ',
              const TextStyle(
                fontSize: 12,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              'red',
              const TextStyle(
                fontSize: 12,
                color: Color(0xFFFF0000),
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              ' and this one will be ',
              const TextStyle(
                fontSize: 12,
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              'blue',
              const TextStyle(
                fontSize: 12,
                color: Color(0xFF0000FF),
              ),
            ),
            (el) => _expectElementTextPainter(
              el,
              '.',
              const TextStyle(
                fontSize: 12,
              ),
            ),
          ]),
        ]),
      ]);
    });
  });
}

// node expects

void _expectStrikethrough(InlineTextNode node, String text) {
  expect(node, isA<StrikethroughTextNode>());
  final content = (node as StrikethroughTextNode).child;
  expect(content, isA<PlainTextNode>());
  expect((content as PlainTextNode).text, text);
}

void _expectBold(InlineTextNode node, String text) {
  expect(node, isA<BoldTextNode>());
  final content = (node as BoldTextNode).child;
  expect(content, isA<PlainTextNode>());
  expect((content as PlainTextNode).text, text);
}

void _expectBoldGroup(
  InlineTextNode node,
  List<void Function(InlineTextNode)> expectChildren,
) {
  expect(node, isA<BoldTextNode>());
  final content = (node as BoldTextNode).child;
  _expectGroup(content, expectChildren);
}

void _expectItalicGroup(
  InlineTextNode node,
  List<void Function(InlineTextNode)> expectChildren,
) {
  expect(node, isA<ItalicTextNode>());
  final content = (node as ItalicTextNode).child;
  _expectGroup(content, expectChildren);
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

void _expectCustom(
  InlineTextNode node,
  String text, {
  required String styleName,
}) {
  expect(node, isA<CustomInlineTextNode>());
  final custom = node as CustomInlineTextNode;
  expect(custom.child, isA<PlainTextNode>());
  expect((custom.child as PlainTextNode).text, text);
  expect(custom.styleName, styleName);
}

void _expectCode(InlineTextNode node, String text) {
  expect(node, isA<CodeTextNode>());
  final content = (node as CodeTextNode).child;
  expect(content, isA<PlainTextNode>());
  expect((content as PlainTextNode).text, text);
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
  for (final (index, expectChild) in expectChildren.indexed) {
    expectChild(group.children[index]);
  }
}

void _expectDocument(
  DocumentRoot root,
  List<void Function(BlockNode)> expectChildren,
) {
  expect(root.children, hasLength(expectChildren.length));
  for (final (index, expectChild) in expectChildren.indexed) {
    expectChild(root.children[index]);
  }
}

// element expects

void _expectElementGroup(
  TextElement element,
  List<void Function(TextElement)> expectChildren,
) {
  expect(element, isA<GroupElement>());
  final group = element as GroupElement;
  expect(group.children, hasLength(expectChildren.length));
  for (final (index, expectChild) in expectChildren.indexed) {
    expectChild(group.children[index]);
  }
}

void _expectElementGroupText(
  TextElement element,
  List<void Function(TextElement)> expectChildren,
) {
  expect(element, isA<GroupTextElement>());
  final group = element as GroupTextElement;
  expect(group.children, hasLength(expectChildren.length));
  for (final (index, expectChild) in expectChildren.indexed) {
    expectChild(group.children[index]);
  }
}

void _expectElementTextPainter(
  TextElement element,
  String text,
  TextStyle style,
) {
  expect(element, isA<TextPainterTextElement>());
  final textPainterElement = element as TextPainterTextElement;
  expect(textPainterElement.textPainter.text!.toPlainText(), text);
  expect(textPainterElement.textPainter.text!.style, style);
}
