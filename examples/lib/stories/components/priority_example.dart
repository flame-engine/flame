import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';

class PriorityExample extends FlameGame with HasTappables {
  static const String description = '''
    On this example, click on the square to bring them to the front by changing
    the priority.
  ''';

  @override
  Future<void> onLoad() async {
    final squares = [
      Square(Vector2(100, 100)),
      Square(Vector2(160, 100)),
      Square(Vector2(170, 150)),
      Square(Vector2(110, 150)),
    ];
    addAll(squares);
  }
}

class Square extends Rectangle with HasGameRef<PriorityExample>, Tappable {
  Square(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(100),
          paint: PaintExtension.random(withAlpha: 0.9, base: 100),
        );

  @override
  bool onTapDown(TapDownInfo info) {
    final topComponent = gameRef.children.last;
    if (topComponent != this) {
      gameRef.children.changePriority(this, topComponent.priority + 1);
    }
    return false;
  }
}
