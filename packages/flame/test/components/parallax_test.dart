import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_test/flame_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _ParallaxGame extends FlameGame {
  late final ParallaxComponent parallaxComponent;
  late final Vector2? parallaxSize;

  _ParallaxGame({this.parallaxSize}) {
    onGameResize(Vector2.all(500));
  }

  @override
  Future<void> onLoad() async {
    parallaxComponent = await loadParallaxComponent(
      [],
      size: parallaxSize,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );
    add(parallaxComponent);
  }
}

class MockImages extends Mock implements Images {}

class MockImage extends Mock implements Image {
  @override
  int get height => 100;

  @override
  int get width => 100;
}

class _SlowLoadParallaxGame extends FlameGame {
  late final ParallaxComponent parallaxComponent;
  late final Vector2? parallaxSize;

  _SlowLoadParallaxGame({this.parallaxSize}) {
    onGameResize(Vector2.all(500));
  }

  @override
  Future<void> onLoad() async {
    final mockImageCache = MockImages();

    void createMockAnswer(int imageNumber, int time) {
      when(() => mockImageCache.load('$imageNumber.png')).thenAnswer(
        (_) {
          return Future<Image>.delayed(
            Duration(milliseconds: time * 100),
            () => Future.value(MockImage()),
          );
        },
      );
    }

    // [3, 5, 1, 6, 2]
    List<void>.generate(
      5,
      (i) => createMockAnswer(i, ((i % 2) + 1) * 3 - i % 3),
    );

    final imagesData = List.generate(5, (i) => ParallaxImageData('$i.png'));

    parallaxComponent = await loadParallaxComponent(
      imagesData,
      size: parallaxSize,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
      images: mockImageCache,
    );
    add(parallaxComponent);
  }
}

void main() {
  final parallaxGame = FlameTester(_ParallaxGame.new);
  final slowLoadParallaxGame = FlameTester(_SlowLoadParallaxGame.new);

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

    slowLoadParallaxGame.test('can have layers with different loading times',
        (game) async {
      final parallax = game.parallaxComponent.parallax!;
      var lastLength = 0.0;
      for (final layer in parallax.layers) {
        final velocityLength = layer.velocityMultiplier.length;
        expect(velocityLength > lastLength, isTrue);
        lastLength = velocityLength;
      }
    });
  });
}
