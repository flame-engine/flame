import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  final image = await generateImage();

  group('UnifiedAnimationChildComponent', () {
    test('correctly delegates rendering to shared ticker', () async {
      final animation = SpriteAnimation.spriteList(
        [Sprite(image), Sprite(image)],
        stepTime: 1,
        loop: true,
      );
      final ticker = animation.createTicker();

      final component = UnifiedAnimationChildComponent(
        animationTicker: ticker,
        size: Vector2.all(100),
      );

      expect(component.animationTicker, ticker);
      expect(ticker.currentIndex, 0);

      // Updating the ticker should affect what the component renders
      ticker.update(1.1);
      expect(ticker.currentIndex, 1);
    });

    test('is a lightweight PositionComponent', () {
      final animation = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      );
      final ticker = animation.createTicker();

      final component = UnifiedAnimationChildComponent(
        animationTicker: ticker,
        position: Vector2(10, 20),
        size: Vector2.all(50),
      );

      expect(component, isA<PositionComponent>());
      expect(component.position, Vector2(10, 20));
      expect(component.size, Vector2.all(50));
    });

    testWithFlameGame('renders correctly with paint', (game) async {
      final animation = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      );
      final ticker = animation.createTicker();
      final paint = Paint()..color = const Color(0xFFFF0000);

      final component = UnifiedAnimationChildComponent(
        animationTicker: ticker,
        size: Vector2.all(100),
        paint: paint,
      );

      await game.ensureAdd(component);
      expect(component.paint.color, const Color(0xFFFF0000));
    });
  });
}
