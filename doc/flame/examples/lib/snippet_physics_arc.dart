import 'package:doc_flame_examples/flower.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class SnippetPhysicsArcGame extends FlameGame with HasTappableComponents {
  final double _initialAngle = 30.0;
  final double _initialVelocity = -300; // This is negative to counter gravity
  final double _gravity = 10;
  final double _windSpeed = 2;
  late Vector2 _velocity;
  late Flower flower;
  bool flowerMove = false;

  @override
  Future<void> onLoad() async {
    _velocity = Vector2(_initialAngle, _initialVelocity);
    flower = Flower(
      size: 20,
      position: Vector2(20, size.y - 20),
      onTap: (flower) {
        flowerMove = true;
      },
    );
    add(flower);
  }

  @override
  void update(double dt) {
    if (flowerMove) {
      _velocity.x += _windSpeed;
      _velocity.y += _gravity;
      flower.position += _velocity * dt;
      //reset when flower is below screen
      if (flower.position.y > size.y) {
        flower.position = Vector2(20, size.y - 20);
        _velocity = Vector2(_initialAngle, _initialVelocity);
        flowerMove = false;
      }
    }

    super.update(dt);
  }
}
