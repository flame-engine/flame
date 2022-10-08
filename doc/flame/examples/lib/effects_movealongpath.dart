import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class MoveAlongPathGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
  final effect = MoveAlongPathEffect(
    Path()..quadraticBezierTo(100, 0, 50, -50),
    EffectController(duration: 1.5),
  );
    final flower = Flower(
      size: 60,
      position: canvasSize / 2,
      onTap: (flower) {
        flower.add(effect),
    );
    add(flower);
  }
}
