import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

final _size = Vector2(100, 100);

void main() {
  group('text layouting', () {
    testGolden(
      'Text is properly laid out across multiple lines',
      (game, tester) async {
        game.addAll([
          RectangleComponent(
            size: _size,
            paint: Paint()..color = const Color(0xffcfc6e5),
          ),
          TextElementComponent.fromDocument(
            document: DocumentRoot([
              ParagraphNode.group(
                ['012345', '67 89'].map(PlainTextNode.new).toList(),
              ),
            ]),
            style: DocumentStyle(
              text: InlineTextStyle(
                // using DebugTextRenderer, this will make each char 10px wide
                fontSize: 10,
              ),
            ),
            size: _size,
          ),
        ]);
      },
      goldenFile: '../_goldens/text_layouting_1.png',
      size: _size,
    );
  });
}
