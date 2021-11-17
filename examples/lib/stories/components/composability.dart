import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

// This class only has `HasDraggables` since the game-in-game example moves a
// draggable component to this game.
class ComposabilityExample extends FlameGame with HasDraggables {
  static const String description = '''
    In this example we showcase how you can add children to a component and how
    they transform together with their parent, if the parent is a
    `PositionComponent`. This example is not interactive.
  ''';

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

class ParentSquare extends RectangleComponent with HasGameRef {
  ParentSquare(Vector2 position, Vector2 size)
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    createChildren();
  }

  void createChildren() {
    // All positions here are in relation to the parent's position
    const childSize = 50.0;
    final children = [
      RectangleComponent.square(
        position: Vector2(100, 100),
        size: childSize,
        angle: 2,
      ),
      RectangleComponent.square(
        position: Vector2(160, 100),
        size: childSize,
        angle: 3,
      ),
      RectangleComponent.square(
        position: Vector2(170, 150),
        size: childSize,
        angle: 4,
      ),
      RectangleComponent.square(
        position: Vector2(70, 200),
        size: childSize,
        angle: 5,
      ),
    ];

    addAll(children);
  }
}
