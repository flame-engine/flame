import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class ParallaxGame extends FlameGame {
  late final ParallaxComponent parallaxComponent;
  late final Vector2? parallaxSize;

  ParallaxGame({this.parallaxSize}) {
    onGameResize(Vector2.all(500));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    parallaxComponent = await loadParallaxComponent(
      [],
      size: parallaxSize,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(parallaxComponent);
  }
}

void main() {
  group('parallax test', () {
    test('can have non-fullscreen ParallaxComponent', () async {
      final parallaxSize = Vector2.all(100);
      final game = ParallaxGame(parallaxSize: parallaxSize.clone());
      await game.onLoad();
      game.update(0);
      expect(game.parallaxComponent.size, parallaxSize);
    });

    test('can have fullscreen ParallaxComponent', () async {
      final game = ParallaxGame();
      await game.onLoad();
      game.update(0);
      expect(game.parallaxComponent.size, game.size);
    });
  });
}
