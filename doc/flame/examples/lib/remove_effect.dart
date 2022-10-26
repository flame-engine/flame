import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class RemoveEffectGame extends FlameGame with TapDetector {
  static const double delayTime = 3;
  late EmberPlayer flower;
  late TextComponent textComponent;
  late RemoveEffect effect = RemoveEffect(delay: delayTime);

  @override
  Future<void> onLoad() async {
    add(
      flower = EmberPlayer(
        position: size / 2,
        size: Vector2(45, 40),
      )..anchor = Anchor.center,
    );
    add(textComponent = TextComponent()..position = Vector2.all(5));
  }

  @override
  void onTap() {
    if (!children.contains(flower)) {
      effect.reset();
      add(flower);
    } else {
      flower.add(effect);
    }
  }

  @override
  void update(double dt) {
    textComponent.text =
        (effect.controller.progress * delayTime).toStringAsFixed(2);
    super.update(dt);
  }
}
