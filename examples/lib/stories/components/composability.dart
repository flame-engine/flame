import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class Square extends PositionComponent {
  Square(Vector2 position, Vector2 size, {double angle = 0})
      : super(
          position: position,
          size: size,
          angle: angle,
        );
}

class ParentSquare extends Square with HasGameRef {
  ParentSquare(Vector2 position, Vector2 size) : super(position, size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    createChildren();
  }

  void createChildren() {
    // All positions here are in relation to the parent's position
    final children = [
      Square(Vector2(100, 100), Vector2(50, 50), angle: 2),
      Square(Vector2(160, 100), Vector2(50, 50), angle: 3),
      Square(Vector2(170, 150), Vector2(50, 50), angle: 4),
      Square(Vector2(70, 200), Vector2(50, 50), angle: 5),
    ];

    addAll(children);
  }
}

// This class only has `HasDraggableComponents` since the game-in-game example
// moves a draggable component to this game.
class Composability extends FlameGame with HasDraggableComponents {
  late ParentSquare parentSquare;

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    parentSquare = ParentSquare(Vector2.all(200), Vector2.all(300))
      ..anchor = Anchor.center;
    add(parentSquare);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parentSquare.angle += dt;
  }
}
