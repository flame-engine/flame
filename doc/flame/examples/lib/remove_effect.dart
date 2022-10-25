import 'package:doc_flame_examples/flower.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class RemoveEffectGame extends FlameGame with TapDetector {
  late Flower flower;
  late TextComponent textComponent;
  late RemoveEffect effect;

  @override
  Future<void> onLoad() async {
    add(
      flower = Flower(
        position: size / 2,
        size: 45,
      )..anchor = Anchor.center,
    );
    add(textComponent = TextComponent()..position = Vector2.all(5));
  }

  @override
  void onTap() {
    if (!children.contains(flower)) {
      add(flower);
    } else {
      flower.add(
        effect = RemoveEffect(delay: 3),
      );
    }
  }

  @override
  void update(double dt) {
    textComponent.text = '${effect.controller.progress}';
    super.update(dt);
  }
}
