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

    children.forEach((c) => add(c, gameRef: gameRef));
  }
}

class Composability extends BaseGame with TapDetector {
  late ParentSquare _parent;

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    _parent = ParentSquare(Vector2.all(400), Vector2.all(250))
      ..anchor = Anchor.center;
    add(_parent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _parent.angle += dt / 2;
  }

  @override
  void onTap() {
    super.onTap();
    _parent.scale = Vector2.all(1.5);
  }
}
