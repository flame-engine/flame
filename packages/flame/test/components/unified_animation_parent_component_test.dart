import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockImage extends Mock implements Image {
  @override
  int get width => 100;
  @override
  int get height => 100;
  @override
  bool get debugDisposed => false;
}

Future<void> main() async {
  group('UnifiedAnimationParentComponent', () {
    test('updates positions based on velocity', () {
      final image = _MockImage();
      final ticker = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      ).createTicker();

      final parent = UnifiedAnimationParentComponent(
        spriteBatch: SpriteBatch(image),
        ticker: ticker,
      );

      parent.addInstance(
        position: Vector2(10, 10),
        size: Vector2.all(10),
        velocity: Vector2(100, 0),
      );

      expect(parent.positions[0], Vector2(10, 10));

      parent.update(0.1); // Move 10 pixels right
      expect(parent.positions[0].x, closeTo(20, 0.001));
    });

    test('manages multiple instances and colors', () {
      final image = _MockImage();
      final ticker = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      ).createTicker();

      final parent = UnifiedAnimationParentComponent(
        spriteBatch: SpriteBatch(image),
        ticker: ticker,
      );

      parent.addInstance(
        position: Vector2(0, 0),
        size: Vector2.all(10),
        color: const Color(0xFFFF0000),
      );

      parent.addInstance(
        position: Vector2(20, 20),
        size: Vector2.all(10),
        color: const Color(0xFF00FF00),
      );

      expect(parent.positions.length, 2);
      expect(parent.colors[0], const Color(0xFFFF0000));
      expect(parent.colors[1], const Color(0xFF00FF00));
    });

    testWithFlameGame('clears instances if needed (manual check)', (
      game,
    ) async {
      final image = await generateImage();
      final ticker = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      ).createTicker();

      final parent = UnifiedAnimationParentComponent(
        spriteBatch: SpriteBatch(image),
        ticker: ticker,
      );

      parent.addInstance(
        position: Vector2.zero(),
        size: Vector2.all(10),
      );

      await game.ensureAdd(parent);
      expect(parent.positions.length, 1);
    });

    testWithFlameGame(
      'renders instances in Y-sorted order when depthSort is enabled',
      (game) async {
        final image = await generateImage();
        final ticker = SpriteAnimation.spriteList(
          [Sprite(image)],
          stepTime: 1,
        ).createTicker();

        final parent = UnifiedAnimationParentComponent(
          spriteBatch: SpriteBatch(image),
          ticker: ticker,
          depthSort: true,
        );

        // Add instances in reverse Y order
        parent.addInstance(
          position: Vector2(0, 100),
          size: Vector2.all(10),
        );
        parent.addInstance(
          position: Vector2(0, 50),
          size: Vector2.all(10),
        );

        // Initially indices are [0, 1]
        expect(parent.positions[0].y, 100);
        expect(parent.positions[1].y, 50);

        // Rebuild batch should sort indices: index 1 (Y=50) comes before index 0 (Y=100)
        parent.update(0);
        parent.render(Canvas(PictureRecorder()));

        // The indices list should be [1, 0] after sorting
        expect(parent.indices, [1, 0]);
      },
    );

    test('updates colorFilter successfully', () {
      final image = _MockImage();
      final ticker = SpriteAnimation.spriteList(
        [Sprite(image)],
        stepTime: 1,
      ).createTicker();

      const filter = ColorFilter.mode(Color(0xFF00FF00), BlendMode.srcIn);
      final parent = UnifiedAnimationParentComponent(
        spriteBatch: SpriteBatch(image),
        ticker: ticker,
        colorFilter: filter,
      );

      expect(parent.colorFilter, filter);

      const newFilter = ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn);
      parent.colorFilter = newFilter;
      expect(parent.colorFilter, newFilter);
    });
  });
}
