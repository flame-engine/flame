import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:test/test.dart';

final _size = Vector2(320, 300); // 3 sets of 10 + 1 space

void main() {
  group('text layouting', () {
    testGolden(
      'Text is properly laid out across multiple lines',
      (game) async {
        game.addAll([
          RectangleComponent(
            size: _size,
            paint: Paint()..color = const Color(0xffcfc6e5),
          ),
          TextElementComponent.fromDocument(
            document: DocumentRoot([
              ParagraphNode.group(
                List.filled(10, PlainTextNode(' 1234567890')),
              ),
            ]),
            style: DocumentStyle(
              text: InlineTextStyle(
                // using DebugTextRenderer, this will make each character 10px wide
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
