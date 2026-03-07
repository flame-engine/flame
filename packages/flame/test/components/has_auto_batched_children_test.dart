import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCanvas extends Mock implements Canvas {}

class _FakeImage extends Fake implements Image {}

class _AutoBatchGroup extends PositionComponent with HasAutoBatchedChildren {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Image sharedImage;

  setUpAll(() async {
    registerFallbackValue(_FakeImage());
    registerFallbackValue(Paint());
    registerFallbackValue(Rect.zero);
    sharedImage = await generateImage(16, 16);
  });

  group('HasAutoBatchedChildren', () {
    group('batchingEnabled', () {
      testWithFlameGame(
        'batches eligible SpriteComponent children into one drawAtlas call',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          for (var i = 0; i < 3; i++) {
            await group.ensureAdd(
              SpriteComponent(
                sprite: sprite,
                size: Vector2.all(16),
                position: Vector2(i * 20.0, 0),
              ),
            );
          }

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(1);
          verifyNever(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          );
        },
      );

      testWithFlameGame(
        'renders each sprite individually when batchingEnabled is false',
        (game) async {
          final group = _AutoBatchGroup()..batchingEnabled = false;
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          for (var i = 0; i < 3; i++) {
            await group.ensureAdd(
              SpriteComponent(
                sprite: sprite,
                size: Vector2.all(16),
                position: Vector2(i * 20.0, 0),
              ),
            );
          }

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verifyNever(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verify(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).called(3);
        },
      );

      testWithFlameGame(
        'toggling batchingEnabled off then on resumes batching',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          await group.ensureAdd(
            SpriteComponent(sprite: sprite, size: Vector2.all(16)),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              position: Vector2(20, 0),
            ),
          );

          final canvas = _MockCanvas();

          group.renderTree(canvas); // frame 1: on  → 1 drawAtlas
          group.batchingEnabled = false;
          group.renderTree(canvas); // frame 2: off → 2 drawImageRect
          group.batchingEnabled = true;
          group.renderTree(canvas); // frame 3: on again → 1 drawAtlas

          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(2); // frames 1 and 3
          verify(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).called(2); // frame 2 only
        },
      );
    });

    group('eligibility', () {
      testWithFlameGame(
        'component with children falls back to individual rendering',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          // Adding a child before mounting — it will be queued and mounted
          // once the parent is in the tree.
          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          final parentComp = SpriteComponent(
            sprite: sprite,
            size: Vector2.all(16),
          )..add(PositionComponent()); // has children → ineligible

          await group.ensureAdd(parentComp);
          // Extra tick to ensure the queued PositionComponent child is mounted.
          await game.ready();

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verifyNever(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verify(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).called(1);
        },
      );

      testWithFlameGame(
        'SpriteComponent with hitbox-only children is still batch-eligible',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          for (var i = 0; i < 2; i++) {
            // Simulate a bullet/enemy: sprite + physics hitbox child.
            final comp = SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              position: Vector2(i * 20.0, 0),
            )..add(CircleHitbox());
            await group.ensureAdd(comp);
          }
          await game.ready(); // ensure hitbox is mounted before rendering

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          // Both sprites should be batched despite each having a hitbox child.
          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(1);
          verifyNever(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          );
        },
      );

      testWithFlameGame(
        'non-uniform scale falls back to individual rendering',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          await group.ensureAdd(
            SpriteComponent(
              sprite: Sprite(sharedImage, srcSize: Vector2.all(16)),
              size: Vector2.all(16),
              scale: Vector2(1, 2), // non-uniform → ineligible
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verifyNever(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verify(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).called(1);
        },
      );

      testWithFlameGame(
        '''mismatched size-to-source aspect ratio falls back to individual rendering''',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          // Source is 16×16 (1:1); size is 16×32 (1:2) → ratio mismatch.
          await group.ensureAdd(
            SpriteComponent(
              sprite: Sprite(sharedImage, srcSize: Vector2.all(16)),
              size: Vector2(16, 32),
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verifyNever(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          );
          verify(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).called(1);
        },
      );

      testWithFlameGame(
        'component size larger than source rect is still batch-eligible',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          // Source is 8×8, display size is 16×16 → 2× stretch, but 1:1 ratio.
          final sprite = Sprite(sharedImage, srcSize: Vector2.all(8));
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
            ),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              position: Vector2(20, 0),
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(1);
          verifyNever(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          );
        },
      );
    });

    group('batching', () {
      testWithFlameGame(
        'separate priority groups produce separate drawAtlas calls',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          // priority=0 — 2 sprites
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              priority: 0,
            ),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              priority: 0,
            ),
          );
          // priority=1 — 2 sprites
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              priority: 1,
            ),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              priority: 1,
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          // One drawAtlas call per priority group.
          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(2);
          verifyNever(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          );
        },
      );

      testWithFlameGame(
        'different images produce separate drawAtlas calls',
        (game) async {
          final image2 = await generateImage(8, 8);
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          await group.ensureAdd(
            SpriteComponent(
              sprite: Sprite(sharedImage, srcSize: Vector2.all(16)),
              size: Vector2.all(16),
            ),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: Sprite(image2, srcSize: Vector2.all(8)),
              size: Vector2.all(8),
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(2);
        },
      );

      testWithFlameGame(
        'batches eligible SpriteAnimationComponent children',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final animation = SpriteAnimation.spriteList(
            [
              Sprite(
                sharedImage,
                srcPosition: Vector2.zero(),
                srcSize: Vector2.all(8),
              ),
              Sprite(
                sharedImage,
                srcPosition: Vector2(8, 0),
                srcSize: Vector2.all(8),
              ),
            ],
            stepTime: 1.0,
          );

          await group.ensureAdd(
            SpriteAnimationComponent(
              animation: animation,
              size: Vector2.all(8),
            ),
          );
          await group.ensureAdd(
            SpriteAnimationComponent(
              animation: animation,
              size: Vector2.all(8),
              position: Vector2(10, 0),
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas);

          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(1);
          verifyNever(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          );
        },
      );

      testWithFlameGame(
        'accumulators are correctly reset between render frames',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));
          await group.ensureAdd(
            SpriteComponent(sprite: sprite, size: Vector2.all(16)),
          );
          await group.ensureAdd(
            SpriteComponent(
              sprite: sprite,
              size: Vector2.all(16),
              position: Vector2(20, 0),
            ),
          );

          final canvas = _MockCanvas();
          group.renderTree(canvas); // frame 1
          group.renderTree(canvas); // frame 2

          // Each frame → exactly one drawAtlas call.
          verify(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).called(2);
        },
      );
    });

    group('render order', () {
      testWithFlameGame(
        '''eligible children flush before a non-eligible sibling at same priority''',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));

          // Eligible first (lower insertion order → rendered before)
          final eligibleSprite = SpriteComponent(
            sprite: sprite,
            size: Vector2.all(16),
            priority: 0,
          );

          // Non-eligible: has a child component
          final nonEligible = SpriteComponent(
            sprite: sprite,
            size: Vector2.all(16),
            priority: 0,
          )..add(PositionComponent());

          await group.ensureAdd(eligibleSprite);
          await group.ensureAdd(nonEligible);
          await game.ready(); // Ensure nested child of nonEligible is mounted.

          final drawOrder = <String>[];
          final canvas = _MockCanvas();
          when(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((_) => drawOrder.add('atlas'));
          when(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).thenAnswer((_) => drawOrder.add('imageRect'));

          group.renderTree(canvas);

          // The eligible sprite is accumulated first; when the non-eligible
          // sibling is encountered, the pending batch is flushed (atlas), then
          // the non-eligible renders its own sprite (imageRect).
          expect(drawOrder, ['atlas', 'imageRect']);
        },
      );

      testWithFlameGame(
        'non-eligible child renders before a subsequent eligible batch',
        (game) async {
          final group = _AutoBatchGroup();
          await game.ensureAdd(group);

          final sprite = Sprite(sharedImage, srcSize: Vector2.all(16));

          // Non-eligible first (has child)
          final nonEligible = SpriteComponent(
            sprite: sprite,
            size: Vector2.all(16),
            priority: 0,
          )..add(PositionComponent());

          // Eligible after
          final eligibleSprite = SpriteComponent(
            sprite: sprite,
            size: Vector2.all(16),
            priority: 0,
          );

          await group.ensureAdd(nonEligible);
          await group.ensureAdd(eligibleSprite);
          await game.ready();

          final drawOrder = <String>[];
          final canvas = _MockCanvas();
          when(
            () => canvas.drawAtlas(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((_) => drawOrder.add('atlas'));
          when(
            () => canvas.drawImageRect(any(), any(), any(), any()),
          ).thenAnswer((_) => drawOrder.add('imageRect'));

          group.renderTree(canvas);

          // Non-eligible renders immediately (imageRect), then eligible is
          // accumulated and flushed at afterChildrenRendered (atlas).
          expect(drawOrder, ['imageRect', 'atlas']);
        },
      );
    });
  });
}
