import 'package:doc_flame_examples/flower.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class RotateAroundEffectGame extends FlameGame {
  bool reset = false;

  @override
  Future<void> onLoad() async {
    final flower = Flower(
      size: 60,
      position: canvasSize / 4,
      onTap: (flower) {
        flower.add(
          RotateAroundEffect(
            reset != reset ? tau : -tau,
            center: canvasSize / 2,
            EffectController(duration: 1),
          ),
        );
        reset = !reset;
      },
    );
    add(flower);
  }
}
