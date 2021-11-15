import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
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
  final parallaxGame = FlameTester(() => ParallaxGame());

  group('parallax test', () {
    parallaxGame.test(
      'can have non-fullscreen ParallaxComponent',
      (game) async {
        final parallaxSize = Vector2.all(100);
        game.onGameResize(parallaxSize);
        expect(game.parallaxComponent.size, parallaxSize);
      },
    );

    parallaxGame.test('can have fullscreen ParallaxComponent', (game) async {
      expect(game.parallaxComponent.size, game.size);
    });
  });
}
