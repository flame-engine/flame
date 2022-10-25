import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class RemoveEffectGame extends FlameGame with TapDetector {
  late Flower flower;
  late TextComponent text;
  late Timer countDown;

  @override
  Future<void> onLoad() async {
    add(
      flower = Flower(
        position: size / 2,
        size: 45,
        onTap: (flower) {
          flower.add(
            RemoveEffect(delay: 3),
          );
        },
      )..anchor = Anchor.center,
    );
    add
    add(text = TextComponent(text: countDown.current.toString()));
  }

  @override
  void onTap() {
    if (!children.contains(flower)) {
      add(flower);
    }
  }
}
