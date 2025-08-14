import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ResizingRectangle extends RectangleComponent {
  ResizingRectangle()
    : super(
        paint: Paint()..color = const Color(0xFFFE4813),
      );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    this.size = size * 0.4;
  }
}

class ResizeExampleGame extends FlameGame {
  ResizeExampleGame() : super(children: [ResizingRectangle()]);

  static const description = '''
    This example shows how to react to the game being resized.

    The rectangle will always be 40% of the screen size.

    Try resizing the window and see the rectangle change its size.
  ''';
}
