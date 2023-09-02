import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_markdown/flame_markdown.dart';
import 'package:flutter/widgets.dart' hide Animation;

void main() {
  runApp(GameWidget(game: MarkdownGame()));
}

/// This example game showcases ...
class MarkdownGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final markdown = await Flame.assets.readFile('fire_and_ice.md');
    await add(
      TextElementComponent.fromDocument(
        document: FlameMarkdown.toDocument(markdown),
      ),
    );
    await super.onLoad();
  }
}

class TextElementComponent extends PositionComponent {
}
