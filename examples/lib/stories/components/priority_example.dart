import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class PriorityExample extends FlameGame {
  static const String description = '''
    On this example, click on the square to bring them to the front by changing
    the priority.
  ''';

  PriorityExample()
      : super(
          children: [
            Square(Vector2(100, 100)),
            Square(Vector2(160, 100)),
            Square(Vector2(170, 150)),
            Square(Vector2(110, 150)),
          ],
        );
}

class Square extends RectangleComponent
    with HasGameReference<PriorityExample>, TapCallbacks {
  Square(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(100),
          paint: PaintExtension.random(withAlpha: 0.9, base: 100),
        );

  @override
  void onTapDown(TapDownEvent event) {
    final topComponent = game.children.last;
    if (topComponent != this) {
      priority = topComponent.priority + 1;
    }
  }
}
