import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class MoveByGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
  final effect = MoveByEffect(Vector2(0, -10), EffectController(duration: 0.5));
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(effect),
    );
    add(flower);
  }
}
