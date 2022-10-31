import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class BenchmarkExample extends FlameGame with TapDetector {
  static const description = '''
See how many SpriteAnimationComponent's your platform can handle before it
starts to drop in FPS, this is without any sprite batching and such.
100 animation components are added per tap.
  ''';

  final emberSize = Vector2.all(20);
  late final TextComponent emberCounter;
  final counterPrefix = 'Animations: ';
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    await addAll([
      FpsTextComponent(
        position: size - Vector2(0, 50),
        anchor: Anchor.bottomRight,
      ),
      emberCounter = TextComponent(
        position: size - Vector2(0, 25),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
      Ember(size: emberSize, position: size / 2),
    ]);
    children.register<Ember>();
  }

  @override
  void update(double dt) {
    super.update(dt);
    emberCounter.text = '$counterPrefix ${children.query<Ember>().length}';
  }

  @override
  void onTapDown(TapDownInfo info) {
    final halfWidth = emberSize.x / 2;
    final halfHeight = emberSize.y / 2;
    addAll(
      List.generate(
        100,
        (_) => Ember(
          size: emberSize,
          position: Vector2(
            halfWidth + (size.x - halfWidth) * random.nextDouble(),
            halfHeight + (size.y - halfHeight) * random.nextDouble(),
          ),
        ),
      ),
    );
  }
}
