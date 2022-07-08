import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class RichTextExample extends FlameGame {
  static String description = '';

  @override
  Color backgroundColor() => const Color(0xFF888888);

  @override
  Future<void> onLoad() async {
    add(MyTextComponent()..position=Vector2.all(100));
  }
}

class MyTextComponent extends PositionComponent {
  late final Element element;

  @override
  Future<void> onLoad() async {
    final style = DocumentStyle(
      width: 300,
      height: 200,
      padding: const EdgeInsets.all(10),
      background: BackgroundStyle(color: const Color(0xFFFFFFEE)),
    );
    final document = DocumentNode([
      ParagraphNode.simple('Once upon a time there lived a small girl.'),
      ParagraphNode.simple(
        'She was quite a happy girl, content with her way '
        'of living, and not suicidal even a little bit',
      ),
    ]);
    element = document.format(style);
  }

  @override
  void render(Canvas canvas) {
    element.render(canvas);
  }
}
