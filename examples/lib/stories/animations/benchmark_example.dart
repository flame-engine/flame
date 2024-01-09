import 'dart:math';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class BenchmarkExample extends FlameGame {
  static const description = '''
See how many SpriteAnimationComponent's your platform can handle before it
starts to drop in FPS, this is without any sprite batching and such.
100 animation components are added per tap.
  ''';

  BenchmarkExample() : super(world: BenchmarkWorld());

  final emberSize = Vector2.all(20);
  late final TextComponent emberCounter;
  final counterPrefix = 'Animations: ';

  @override
  Future<void> onLoad() async {
    await camera.viewport.addAll([
      FpsTextComponent(
        position: size - Vector2(10, 50),
        anchor: Anchor.bottomRight,
      ),
      emberCounter = TextComponent(
        position: size - Vector2(10, 25),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    ]);
    world.add(Ember(size: emberSize));
    children.register<Ember>();
  }

  @override
  void update(double dt) {
    super.update(dt);
    emberCounter.text =
        '$counterPrefix ${world.children.query<Ember>().length}';
  }
}

class BenchmarkWorld extends World
    with TapCallbacks, HasGameReference<BenchmarkExample> {
  final Random random = Random();

  @override
  void onTapDown(TapDownEvent event) {
    addAll(
      List.generate(
        100,
        (_) => Ember(
          size: game.emberSize,
          position: Vector2(
            (game.size.x / 2) *
                random.nextDouble() *
                (random.nextBool() ? 1 : -1),
            (game.size.y / 2) *
                random.nextDouble() *
                (random.nextBool() ? 1 : -1),
          ),
        ),
      ),
    );
  }
}
