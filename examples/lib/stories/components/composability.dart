import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Square extends PositionComponent with HasGameRef<Composability> {
  Square(Vector2 position, Vector2 size, {double angle = 0}) {
    this.position.setFrom(position);
    this.size.setFrom(size);
    this.angle = angle;
  }
}

class ParentSquare extends Square {
  ParentSquare(Vector2 position, Vector2 size) : super(position, size);

  @override
  void onMount() {
    super.onMount();
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

    children.forEach(addChild);
  }
}

class Composability extends BaseGame {
  late ParentSquare _parent;

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    _parent = ParentSquare(Vector2.all(200), Vector2.all(300))
      ..anchor = Anchor.center;
    add(_parent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _parent.angle += dt;
  }
}
